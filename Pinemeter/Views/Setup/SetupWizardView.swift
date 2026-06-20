import SwiftUI
import AppKit

struct SetupWizardView: View {
    @Bindable var appModel: AppModel

    @State private var isValidating: Bool = false
    @State private var isImporting: Bool = false
    @State private var errorMessage: String?
    @State private var offersFullDiskAccessSettings: Bool = false
    @State private var hasValidationSucceeded: Bool = false
    @State private var successMessage: String?

    var body: some View {
        let statuses = appModel.providerCredentialStatuses

        VStack(spacing: 18) {
            VStack(spacing: 8) {
                if let appIcon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 64, height: 64)
                } else {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                }

                Text("Welcome to Pinemeter")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Connect browser sessions to monitor LLM plan usage.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)

            VStack(spacing: 12) {
                ForEach(statuses) { status in
                    credentialStatusCard(status)
                }
            }
            .padding(.horizontal, 32)

            if let errorMessage = errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        CopyableErrorText(errorMessage, font: .callout, foregroundStyle: .orange, lineLimit: 3)
                    }

                    if offersFullDiskAccessSettings {
                        Button("Open Full Disk Access") {
                            SystemSettingsOpener.openFullDiskAccess()
                        }
                        .controlSize(.small)
                        .padding(.leading, 28)
                    }
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 32)
                .accessibilityLabel("Error: \(errorMessage)")
            }

            if hasValidationSucceeded, let successMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(successMessage)
                        .font(.callout)
                        .foregroundColor(.green)
                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 32)
            }

            Spacer()

            browserImportActions
        }
        .frame(width: 390, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func credentialStatusCard(_ status: AppProviderCredentialStatus) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: credentialStatusIcon(for: status.state.health))
                .foregroundStyle(credentialStatusColor(for: status.state.health))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(status.setupPromptTitle)
                        .font(.headline)
                    Spacer()
                    Text(status.statusTitle)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(credentialStatusColor(for: status.state.health))
                }

                Text(status.setupPromptDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let lastFailureTitle = status.lastFailureTitle {
                    Text(lastFailureTitle)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(status.setupAccessibilityLabel)
    }

    private func credentialStatusIcon(for health: CredentialHealthState) -> String {
        switch health {
        case .valid:
            return "checkmark.circle.fill"
        case .refreshRecommended:
            return "clock.badge.exclamationmark"
        case .validating:
            return "arrow.triangle.2.circlepath.circle"
        case .invalid, .expired, .unavailable:
            return "exclamationmark.triangle.fill"
        case .missing, .unknown:
            return "questionmark.circle"
        }
    }

    private func credentialStatusColor(for health: CredentialHealthState) -> Color {
        switch health {
        case .valid:
            return .green
        case .refreshRecommended:
            return .orange
        case .validating:
            return .blue
        case .invalid, .expired, .unavailable:
            return .red
        case .missing, .unknown:
            return .secondary
        }
    }

    private var browserImportActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Import signed-in browser sessions")
                .font(.subheadline.weight(.semibold))

            Text("Choose the browser where you are already signed in. Each import button checks both Claude and ChatGPT without showing credential values.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(BrowserImportSource.setupOptions, id: \.self) { source in
                Button(action: {
                    Task {
                        await importProviderSessions(from: source)
                    }
                }) {
                    HStack {
                        if isImporting {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isImporting ? "Importing from \(source.displayName)..." : source.importButtonTitle)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isBusy)
                .accessibilityLabel(source.importButtonTitle)
                .accessibilityHint("Imports both Claude and ChatGPT sessions from \(source.displayName) without showing credential values")
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }

    private var isBusy: Bool {
        isValidating || isImporting
    }

    @MainActor
    private func importProviderSessions(from source: BrowserImportSource) async {
        isImporting = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false
        successMessage = nil

        let outcome = await appModel.importProviderSessions(from: source)
        offersFullDiskAccessSettings = outcome.offersFullDiskAccessSettings

        if outcome.importedCount > 0 {
            successMessage = browserImportSuccessMessage(for: outcome)
            hasValidationSucceeded = true
        }

        if outcome.importedCount < 2 {
            errorMessage = browserImportFailureMessage(for: outcome)
        }

        isImporting = false
    }

    private func browserImportSuccessMessage(for outcome: ProviderBrowserImportOutcome) -> String {
        let importedProviders = [
            providerSuccessName("Claude", outcome.claude),
            providerSuccessName("ChatGPT", outcome.chatGPT),
        ].compactMap { $0 }

        return "Imported \(importedProviders.joined(separator: " and ")) from \(outcome.source.displayName)."
    }

    private func providerSuccessName(_ name: String, _ status: ProviderBrowserImportStatus) -> String? {
        if case .imported = status {
            return name
        }
        return nil
    }

    private func browserImportFailureMessage(for outcome: ProviderBrowserImportOutcome) -> String? {
        let failures = [
            providerFailureMessage("Claude", outcome.claude),
            providerFailureMessage("ChatGPT", outcome.chatGPT),
        ].compactMap { $0 }

        guard !failures.isEmpty else { return nil }
        return failures.joined(separator: " ")
    }

    private func providerFailureMessage(_ name: String, _ status: ProviderBrowserImportStatus) -> String? {
        if case .failed(let message, _) = status {
            return "\(name): \(message)"
        }
        return nil
    }

    @MainActor
    private func repairClaudeSessionKey() async {
        isValidating = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false
        successMessage = nil

        let state = await appModel.repairClaudeSessionKey()
        if state.isUsable {
            successMessage = "Claude access repaired."
            hasValidationSucceeded = true
        } else {
            let status = appModel.providerCredentialStatuses.first { $0.provider == .claude }
            errorMessage = status?.recoverySuggestion ?? status?.statusDescription
        }

        isValidating = false
    }

    @MainActor
    private func clearSavedCredential(for provider: CredentialProvider) async {
        isValidating = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false
        successMessage = nil

        do {
            switch provider {
            case .claude:
                try await appModel.clearSessionKey()
            case .chatGPT:
                try await appModel.clearChatGPTSessionCookie()
            }
        } catch {
            errorMessage = "Failed to clear saved credential: \(error.localizedDescription)"
        }

        isValidating = false
    }
}
