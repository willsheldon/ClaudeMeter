import SwiftUI
import AppKit

struct SetupWizardView: View {
    @Bindable var appModel: AppModel

    @State private var sessionKeyInput: String = ""
    @State private var isValidating: Bool = false
    @State private var isImporting: Bool = false
    @State private var errorMessage: String?
    @State private var offersFullDiskAccessSettings: Bool = false
    @State private var hasValidationSucceeded: Bool = false

    var body: some View {
        let claudeStatus = claudeCredentialStatus

        VStack(spacing: 22) {
            // Header
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

                Text("Monitor your Claude.ai plan usage in real-time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 32)

            credentialStatusCard(claudeStatus)
                .padding(.horizontal, 32)

            if claudeStatus.shouldPromptForSetupCredential {
                claudeSessionKeyInput
                    .padding(.horizontal, 32)
            }

            // Error Message
            if let errorMessage = errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.orange)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
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

            // Success Message
            if hasValidationSucceeded {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Setup complete! Launching Pinemeter...")
                        .font(.callout)
                        .foregroundColor(.green)
                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 32)
            }

            Spacer()

            // Actions
            setupActions(for: claudeStatus)
        }
        .frame(width: 370, height: 460)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    // MARK: - Credential Status

    private var claudeCredentialStatus: AppProviderCredentialStatus {
        appModel.providerCredentialStatuses.first { $0.provider == .claude } ?? AppProviderCredentialStatus(
            state: CredentialState(
                identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
                health: .unknown
            ),
            actions: []
        )
    }

    private var claudeSessionKeyInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Claude Session")
                .font(.headline)

            SecureField("sk-ant-...", text: $sessionKeyInput)
                .textFieldStyle(.roundedBorder)
                .disabled(isBusy)
                .accessibilityLabel("Claude session key input field")
                .accessibilityHint("Enter your Claude session key or paste a Cookie header containing sessionKey")

            Text("Import from a browser signed in to claude.ai, or paste your session")
                .font(.caption)
                .foregroundColor(.secondary)

            // Format validation indicator
            if !sessionKeyInput.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: isFormatValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isFormatValid ? .green : .red)
                    Text(isFormatValid ? "Session format valid" : "Invalid session format")
                        .font(.caption)
                        .foregroundColor(isFormatValid ? .green : .red)
                }
                .accessibilityLabel(isFormatValid ? "Claude session key format valid" : "Claude session key format invalid")
            }
        }
    }

    private func credentialStatusCard(_ status: AppProviderCredentialStatus) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: credentialStatusIcon(for: status.state.health))
                .foregroundStyle(credentialStatusColor(for: status.state.health))
                .frame(width: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
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

    @ViewBuilder
    private func setupActions(for status: AppProviderCredentialStatus) -> some View {
        VStack(spacing: 8) {
            if status.actions.contains(where: { $0.kind == .reconnect }) {
                Button(action: {
                    Task {
                        await importAndSave()
                    }
                }) {
                    HStack {
                        if isImporting {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isImporting ? "Importing..." : "Import from Browser")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)
                .accessibilityLabel(isImporting ? "Importing Claude session key" : "Import Claude session key from browser")
                .accessibilityHint("Finds your Claude session key in local browser cookies and validates it")
            }

            if status.shouldPromptForSetupCredential {
                Button(action: {
                    Task {
                        await validateAndSave()
                    }
                }) {
                    HStack {
                        Text(isValidating ? "Validating..." : "Continue Manually")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .disabled(!isFormatValid || isBusy)
                .accessibilityLabel(isValidating ? "Validating Claude session key" : "Continue with manual setup")
                .accessibilityHint("Validates your Claude session key and completes setup")
            }

            if status.isRepairableInSetup {
                Button(action: {
                    Task {
                        await repairClaudeSessionKey()
                    }
                }) {
                    HStack {
                        if isValidating {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isValidating ? "Repairing..." : "Repair Saved Credential")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .disabled(isBusy || status.state.health == .validating)
                .accessibilityLabel(isValidating ? "Repairing Claude session key" : "Repair saved Claude session key")
                .accessibilityHint("Re-saves the existing Claude session key with the current app identity when possible")

                Button("Clear Saved Credential") {
                    Task {
                        await clearSavedCredential()
                    }
                }
                .buttonStyle(.borderless)
                .disabled(isBusy)
                .accessibilityLabel("Clear saved Claude session key")
                .accessibilityHint("Removes the saved Claude session key from Keychain without displaying it")
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }

    // MARK: - Validation

    private var isBusy: Bool {
        isValidating || isImporting
    }

    private var isFormatValid: Bool {
        let trimmed = sessionKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = SessionKey.extractSessionKeyValue(from: trimmed) else { return false }
        return value.hasPrefix("sk-ant-") && value.count > 10
    }

    @MainActor
    private func importAndSave() async {
        isImporting = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false

        do {
            let imported = try await appModel.importAndSaveSessionKey()
            sessionKeyInput = imported.value
            hasValidationSucceeded = true
        } catch let error as SessionKeyImportError {
            errorMessage = error.localizedDescription
            offersFullDiskAccessSettings = error.offersFullDiskAccessSettings
        } catch let error as NetworkError {
            errorMessage = "Network error: \(error.localizedDescription)"
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }

        isImporting = false
    }

    @MainActor
    private func repairClaudeSessionKey() async {
        isValidating = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false

        let state = await appModel.repairClaudeSessionKey()
        if state.isUsable {
            sessionKeyInput = await appModel.loadSessionKey() ?? ""
            hasValidationSucceeded = true
        } else {
            let status = claudeCredentialStatus
            errorMessage = status.recoverySuggestion ?? status.statusDescription
        }

        isValidating = false
    }

    @MainActor
    private func clearSavedCredential() async {
        isValidating = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false

        do {
            try await appModel.clearSessionKey()
            sessionKeyInput = ""
        } catch {
            errorMessage = "Failed to clear saved credential: \(error.localizedDescription)"
        }

        isValidating = false
    }

    @MainActor
    private func validateAndSave() async {
        guard !sessionKeyInput.isEmpty else {
            errorMessage = "Claude session key cannot be empty"
            hasValidationSucceeded = false
            return
        }

        isValidating = true
        errorMessage = nil
        offersFullDiskAccessSettings = false
        hasValidationSucceeded = false

        do {
            let isValid = try await appModel.validateAndSaveSessionKey(sessionKeyInput)
            if isValid {
                hasValidationSucceeded = true
            } else {
                errorMessage = "Claude session key is invalid or expired"
            }
        } catch let error as SessionKeyError {
            errorMessage = error.localizedDescription
        } catch let error as NetworkError {
            errorMessage = "Network error: \(error.localizedDescription)"
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Validation failed: \(error.localizedDescription)"
        }

        isValidating = false
    }
}
