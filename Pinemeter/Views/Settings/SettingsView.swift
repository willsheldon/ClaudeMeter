import SwiftUI
import ServiceManagement
import AppKit

struct SettingsView: View {
    @Bindable var appModel: AppModel

    @State private var isImportingSessionKey: Bool = false
    @State private var sessionKeyValidationMessage: String?
    @State private var offersFullDiskAccessSettings: Bool = false
    @State private var hasSessionKeyValidationSucceeded: Bool = false

    @State private var isImportingChatGPTSessionCookie: Bool = false
    @State private var chatGPTSessionCookieValidationMessage: String?
    @State private var hasChatGPTSessionCookieValidationSucceeded: Bool = false
    @State private var isImportingProviderSessions: Bool = false
    @State private var providerImportMessage: String?
    @State private var hasProviderImportSucceeded: Bool = false

    @State private var isSendingTestNotification: Bool = false
    @State private var testNotificationMessage: String?
    @State private var hasTestNotificationSucceeded: Bool = false
    @State private var notificationError: String?

    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gearshape") }
            notificationsTab
                .tabItem { Label("Notifications", systemImage: "bell") }
            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 500)
        .onAppear {
            loadSettings()
        }
        .onChange(of: appModel.settings.hasNotificationsEnabled) { _, newValue in
            Task {
                if newValue {
                    await appModel.requestNotificationPermissionIfNeeded()
                }
                await updateNotificationStatus()
            }
        }
        .onChange(of: launchAtLogin) { _, newValue in
            updateLaunchAtLogin(newValue)
        }
    }

    // MARK: - General Tab

    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !appModel.isReady {
                VStack {
                    Spacer()
                    ProgressView("Loading settings...")
                        .controlSize(.large)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                credentialRecoverySection
                chatGPTUsageSection
                refreshIntervalSection
                sonnetUsageSection
                launchAtLoginSection
            }
        }
        .padding(24)
    }

    // MARK: - Credential Recovery Section

    private var credentialRecoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Credential Recovery")
                    .font(.subheadline)
                Text("Claude appears first. Status and recovery actions never show saved credential values.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            credentialBrowserImportButtons

            Divider()

            ForEach(appModel.providerCredentialStatuses) { status in
                providerCredentialRow(status)

                if status.id != appModel.providerCredentialStatuses.last?.id {
                    Divider()
                }
            }

            credentialActionFeedback
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var credentialBrowserImportButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Import signed-in browser sessions")
                .font(.caption.weight(.semibold))

            ForEach(BrowserImportSource.setupOptions, id: \.self) { source in
                Button(action: {
                    Task { await importProviderSessionsFromSettings(source) }
                }) {
                    HStack {
                        if isImportingProviderSessions {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isImportingProviderSessions ? "Importing from \(source.displayName)..." : source.importButtonTitle)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(isCredentialImportBusy)
            }
        }
    }

    @ViewBuilder
    private var credentialActionFeedback: some View {
        if let providerImportMessage {
            CopyableErrorText(providerImportMessage,
                              font: .caption,
                              foregroundStyle: hasProviderImportSucceeded ? Color.green : Color.orange)
        }

        if let sessionKeyValidationMessage {
            CopyableErrorText(sessionKeyValidationMessage,
                              font: .caption,
                              foregroundStyle: hasSessionKeyValidationSucceeded ? Color.green : Color.orange)
        }

        if offersFullDiskAccessSettings {
            Button("Open Privacy & Security Settings") {
                SystemSettingsOpener.openFullDiskAccess()
            }
            .controlSize(.small)
        }

        if let chatGPTSessionCookieValidationMessage {
            CopyableErrorText(chatGPTSessionCookieValidationMessage,
                              font: .caption,
                              foregroundStyle: hasChatGPTSessionCookieValidationSucceeded ? Color.green : Color.orange)
        }
    }

    private func providerCredentialRow(_ status: AppProviderCredentialStatus) -> some View {
        let visibleActions = status.actions.filter { $0.kind != .reconnect }

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: credentialStatusIcon(for: status.state.health))
                    .foregroundStyle(credentialStatusColor(for: status.state.health))
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 4) {
                    Text(status.providerName)
                        .font(.caption.weight(.semibold))

                    Text(status.statusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let lastFailureTitle = status.lastFailureTitle {
                        CopyableErrorText(lastFailureTitle, font: .caption2, foregroundStyle: .orange)
                    }

                    if let recoverySuggestion = status.recoverySuggestion {
                        CopyableErrorText(recoverySuggestion, font: .caption2, foregroundStyle: .secondary)
                    }
                }

                Spacer()

                Text(status.statusTitle)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(credentialStatusColor(for: status.state.health))
            }

            if !visibleActions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(visibleActions) { action in
                        Button(action.displayTitle) {
                            handleCredentialAction(action.kind, for: status)
                        }
                        .controlSize(.small)
                        .disabled(isCredentialActionDisabled(action.kind, for: status))
                    }

                    Spacer()
                }
                .padding(.leading, 30)
            }
        }
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

    // MARK: - ChatGPT Usage Section

    private var chatGPTUsageSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Show ChatGPT Usage")
                    .font(.subheadline)
                Text("Optional. Connect ChatGPT from the credential recovery section, then show ChatGPT plan quota usage in the popover.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("", isOn: $appModel.settings.isChatGPTUsageShown)
                .labelsHidden()
                .disabled(!appModel.hasChatGPTSessionCookie)
                .onChange(of: appModel.settings.isChatGPTUsageShown) { _, isShown in
                    if isShown {
                        Task { await appModel.refreshChatGPTUsage() }
                    }
                }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Refresh Interval Section

    private var refreshIntervalSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Refresh Interval")
                    .font(.subheadline)
                Text("How often to check your usage data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("", selection: $appModel.settings.refreshInterval) {
                Text("1 minute").tag(60.0)
                Text("5 minutes").tag(300.0)
                Text("10 minutes").tag(600.0)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 120)
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Sonnet Usage Section

    private var sonnetUsageSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Show Sonnet Usage")
                    .font(.subheadline)
                Text("Display weekly Sonnet usage in the menu bar popover")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $appModel.settings.isSonnetUsageShown)
                .labelsHidden()
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Launch at Login Section

    private var launchAtLoginSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Start at Login")
                    .font(.subheadline)
                Text("Automatically launch Pinemeter when you log in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $launchAtLogin)
                .labelsHidden()
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Notifications Tab

    private var notificationsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            enableNotificationsSection
            thresholdsSection
                .opacity(appModel.settings.hasNotificationsEnabled ? 1 : 0.5)
                .allowsHitTesting(appModel.settings.hasNotificationsEnabled)
            resetNotificationSection
                .opacity(appModel.settings.hasNotificationsEnabled ? 1 : 0.5)
                .allowsHitTesting(appModel.settings.hasNotificationsEnabled)
            testNotificationSection
                .opacity(appModel.settings.hasNotificationsEnabled ? 1 : 0.5)
                .allowsHitTesting(appModel.settings.hasNotificationsEnabled)
        }
        .padding(24)
    }

    private var enableNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Notifications")
                        .font(.subheadline)
                    Text("Get notified when session usage thresholds are reached")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $appModel.settings.hasNotificationsEnabled)
                    .labelsHidden()
            }

            if let error = notificationError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Open Settings") {
                        openSystemNotificationSettings()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var thresholdsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Warning Threshold")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(warningThresholdValue))%")
                        .foregroundStyle(.orange)
                        .font(.subheadline.monospacedDigit())
                }

                Slider(
                    value: warningThresholdBinding,
                    in: Constants.Thresholds.Notification.warningMin...Constants.Thresholds.Notification.warningMax,
                    step: Constants.Thresholds.Notification.step
                )
                .tint(.orange)

                Text("Get notified when session usage reaches this percentage")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Critical Threshold")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(criticalThresholdValue))%")
                        .foregroundStyle(.red)
                        .font(.subheadline.monospacedDigit())
                }

                Slider(
                    value: criticalThresholdBinding,
                    in: Constants.Thresholds.Notification.criticalMin...Constants.Thresholds.Notification.criticalMax,
                    step: Constants.Thresholds.Notification.step
                )
                .tint(.red)

                Text("Get urgent notification when session usage reaches this percentage")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if criticalThresholdValue <= warningThresholdValue {
                    Label("Critical threshold must be higher than warning", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var resetNotificationSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notify on Session Reset")
                    .font(.subheadline)
                Text("Get notified when your usage limit resets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: isNotifiedOnResetBinding)
                .labelsHidden()
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var testNotificationSection: some View {
        HStack {
            Button("Send Test Notification") {
                Task {
                    await sendTestNotification()
                }
            }
            .controlSize(.small)
            .disabled(isSendingTestNotification)

            if isSendingTestNotification {
                ProgressView()
                    .controlSize(.small)
            }

            if let message = testNotificationMessage {
                Label(message, systemImage: hasTestNotificationSucceeded ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(hasTestNotificationSucceeded ? .green : .red)
            }

            Spacer()
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Bindings

    private var warningThresholdBinding: Binding<Double> {
        Binding(
            get: { appModel.settings.notificationThresholds.warningThreshold },
            set: { appModel.settings.notificationThresholds.warningThreshold = $0 }
        )
    }

    private var criticalThresholdBinding: Binding<Double> {
        Binding(
            get: { appModel.settings.notificationThresholds.criticalThreshold },
            set: { appModel.settings.notificationThresholds.criticalThreshold = $0 }
        )
    }

    private var isNotifiedOnResetBinding: Binding<Bool> {
        Binding(
            get: { appModel.settings.notificationThresholds.isNotifiedOnReset },
            set: { appModel.settings.notificationThresholds.isNotifiedOnReset = $0 }
        )
    }

    private var warningThresholdValue: Double {
        appModel.settings.notificationThresholds.warningThreshold
    }

    private var criticalThresholdValue: Double {
        appModel.settings.notificationThresholds.criticalThreshold
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 24) {
            // App Icon
            if let appIconImage = NSImage(named: "AppIcon") {
                Image(nsImage: appIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            } else {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
            }

            // App Name & Version
            VStack(spacing: 8) {
                Text("Pinemeter")
                    .font(.system(size: 28, weight: .semibold))

                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Version \(version) (\(build))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Copyright
            VStack(spacing: 4) {
                Text("© 2025 Edd Mann")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Monitor your Claude.ai usage limits")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Project Link
            Link(destination: URL(string: "https://github.com/willsheldon/Pinemeter")!) {
                HStack {
                    Image(systemName: "link.circle.fill")
                    Text("View Project on GitHub")
                }
                .frame(maxWidth: 280)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private var isSessionKeyBusy: Bool {
        isImportingSessionKey
    }

    private var isChatGPTSessionCookieBusy: Bool {
        isImportingChatGPTSessionCookie
    }

    private var isCredentialImportBusy: Bool {
        isImportingProviderSessions || isSessionKeyBusy || isChatGPTSessionCookieBusy
    }

    private func loadSettings() {
        Task { @MainActor in
            await updateNotificationStatus()
        }
    }

    @MainActor
    private func updateNotificationStatus() async {
        let hasPermission = await appModel.checkNotificationPermissions()
        if !hasPermission {
            notificationError = "Notifications disabled in System Settings"
            if appModel.settings.hasNotificationsEnabled {
                appModel.settings.hasNotificationsEnabled = false
            }
        } else {
            notificationError = nil
        }
    }

    @MainActor
    private func importProviderSessionsFromSettings(_ source: BrowserImportSource) async {
        isImportingProviderSessions = true
        providerImportMessage = nil
        hasProviderImportSucceeded = false
        sessionKeyValidationMessage = nil
        chatGPTSessionCookieValidationMessage = nil
        offersFullDiskAccessSettings = false

        let outcome = await appModel.importProviderSessions(from: source)
        offersFullDiskAccessSettings = outcome.offersFullDiskAccessSettings

        if outcome.importedCount > 0 {
            providerImportMessage = settingsBrowserImportSuccessMessage(for: outcome)
            hasProviderImportSucceeded = true
        } else {
            providerImportMessage = settingsBrowserImportFailureMessage(for: outcome)
            hasProviderImportSucceeded = false
        }

        isImportingProviderSessions = false
    }

    private func settingsBrowserImportSuccessMessage(for outcome: ProviderBrowserImportOutcome) -> String {
        let importedProviders = [
            settingsProviderSuccessName("Claude", outcome.claude),
            settingsProviderSuccessName("ChatGPT", outcome.chatGPT),
        ].compactMap { $0 }

        let failureMessage = settingsBrowserImportFailureMessage(for: outcome)
        let success = "Imported \(importedProviders.joined(separator: " and ")) from \(outcome.source.displayName)."
        if let failureMessage, outcome.importedCount < 2 {
            return "\(success) \(failureMessage)"
        }
        return success
    }

    private func settingsProviderSuccessName(_ name: String, _ status: ProviderBrowserImportStatus) -> String? {
        if case .imported = status {
            return name
        }
        return nil
    }

    private func settingsBrowserImportFailureMessage(for outcome: ProviderBrowserImportOutcome) -> String? {
        let failures = [
            settingsProviderFailureMessage("Claude", outcome.claude),
            settingsProviderFailureMessage("ChatGPT", outcome.chatGPT),
        ].compactMap { $0 }

        guard !failures.isEmpty else { return nil }
        return failures.joined(separator: " ")
    }

    private func settingsProviderFailureMessage(_ name: String, _ status: ProviderBrowserImportStatus) -> String? {
        if case .failed(let message, _) = status {
            return "\(name): \(message)"
        }
        return nil
    }

    @MainActor
    private func importAndSaveSessionKey() async {
        isImportingSessionKey = true
        sessionKeyValidationMessage = nil
        offersFullDiskAccessSettings = false
        hasSessionKeyValidationSucceeded = false

        do {
            let imported = try await appModel.importAndSaveSessionKey()
            sessionKeyValidationMessage = "Imported from \(imported.sourceDescription)"
            hasSessionKeyValidationSucceeded = true
            offersFullDiskAccessSettings = false

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                sessionKeyValidationMessage = nil
                offersFullDiskAccessSettings = false
                hasSessionKeyValidationSucceeded = false
            }
        } catch let error as SessionKeyImportError {
            sessionKeyValidationMessage = error.localizedDescription
            offersFullDiskAccessSettings = error.offersFullDiskAccessSettings
            hasSessionKeyValidationSucceeded = false
        } catch {
            sessionKeyValidationMessage = error.localizedDescription
            offersFullDiskAccessSettings = false
            hasSessionKeyValidationSucceeded = false
        }

        isImportingSessionKey = false
    }

    private func clearSessionKey() {
        Task { @MainActor in
            await clearSessionKeyFromSettings()
        }
    }

    @MainActor
    private func clearSessionKeyFromSettings() async {
        do {
            try await appModel.clearSessionKey()
            sessionKeyValidationMessage = nil
            offersFullDiskAccessSettings = false
            hasSessionKeyValidationSucceeded = false
        } catch {
            sessionKeyValidationMessage = "Failed to clear: \(error.localizedDescription)"
            offersFullDiskAccessSettings = false
            hasSessionKeyValidationSucceeded = false
        }
    }

    @MainActor
    private func repairClaudeSessionKeyFromSettings() async {
        sessionKeyValidationMessage = nil
        offersFullDiskAccessSettings = false
        hasSessionKeyValidationSucceeded = false

        let state = await appModel.repairClaudeSessionKey()
        if state.isUsable {
            sessionKeyValidationMessage = "Claude session key repaired"
            hasSessionKeyValidationSucceeded = true
        } else {
            let status = appModel.providerCredentialStatuses.first { $0.provider == .claude }
            sessionKeyValidationMessage = status?.recoverySuggestion ?? status?.statusDescription ?? "Claude session key repair failed"
            hasSessionKeyValidationSucceeded = false
        }
    }

    private func handleCredentialAction(_ kind: ProviderCredentialActionKind, for status: AppProviderCredentialStatus) {
        Task { @MainActor in
            switch (status.provider, kind) {
            case (.claude, .reconnect):
                await importAndSaveSessionKey()
            case (.claude, .repair):
                await repairClaudeSessionKeyFromSettings()
            case (.claude, .clear):
                await clearSessionKeyFromSettings()
            case (.chatGPT, .reconnect), (.chatGPT, .repair):
                await importAndSaveChatGPTSessionCookie()
            case (.chatGPT, .clear):
                await clearChatGPTSessionCookieFromSettings()
            }
        }
    }

    private func isCredentialActionDisabled(_ kind: ProviderCredentialActionKind, for status: AppProviderCredentialStatus) -> Bool {
        switch (status.provider, kind) {
        case (.claude, .reconnect):
            return isSessionKeyBusy
        case (.claude, .repair):
            return isSessionKeyBusy || status.state.health == .validating
        case (.claude, .clear):
            return isSessionKeyBusy
        case (.chatGPT, .reconnect), (.chatGPT, .repair):
            return isChatGPTSessionCookieBusy
        case (.chatGPT, .clear):
            return isChatGPTSessionCookieBusy
        }
    }

    @MainActor
    private func importAndSaveChatGPTSessionCookie() async {
        isImportingChatGPTSessionCookie = true
        chatGPTSessionCookieValidationMessage = nil
        hasChatGPTSessionCookieValidationSucceeded = false

        do {
            let imported = try await appModel.importAndSaveChatGPTSessionCookie()
            chatGPTSessionCookieValidationMessage = "Imported from \(imported.sourceDescription)"
            hasChatGPTSessionCookieValidationSucceeded = true

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                chatGPTSessionCookieValidationMessage = nil
                hasChatGPTSessionCookieValidationSucceeded = false
            }
        } catch let error as SessionKeyImportError {
            chatGPTSessionCookieValidationMessage = error.localizedDescription
            hasChatGPTSessionCookieValidationSucceeded = false
        } catch {
            chatGPTSessionCookieValidationMessage = error.localizedDescription
            hasChatGPTSessionCookieValidationSucceeded = false
        }

        isImportingChatGPTSessionCookie = false
    }

    private func clearChatGPTSessionCookie() {
        Task { @MainActor in
            await clearChatGPTSessionCookieFromSettings()
        }
    }

    @MainActor
    private func clearChatGPTSessionCookieFromSettings() async {
        do {
            try await appModel.clearChatGPTSessionCookie()
            chatGPTSessionCookieValidationMessage = nil
            hasChatGPTSessionCookieValidationSucceeded = false
        } catch {
            chatGPTSessionCookieValidationMessage = "Failed to clear: \(error.localizedDescription)"
            hasChatGPTSessionCookieValidationSucceeded = false
        }
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Revert the toggle if it failed
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    @MainActor
    private func sendTestNotification() async {
        isSendingTestNotification = true
        testNotificationMessage = nil
        hasTestNotificationSucceeded = false

        do {
            let hasPermission = await appModel.checkNotificationPermissions()
            if !hasPermission {
                await appModel.requestNotificationPermissionIfNeeded()
                let granted = await appModel.checkNotificationPermissions()
                if !granted {
                    testNotificationMessage = "Permission denied"
                    hasTestNotificationSucceeded = false
                    isSendingTestNotification = false
                    return
                }
            }

            // Send test notification
            try await appModel.sendTestNotification()

            testNotificationMessage = "Test notification sent!"
            hasTestNotificationSucceeded = true

            // Clear message after 2 seconds
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                testNotificationMessage = nil
                hasTestNotificationSucceeded = false
            }
        } catch {
            testNotificationMessage = "Failed: \(error.localizedDescription)"
            hasTestNotificationSucceeded = false
        }

        isSendingTestNotification = false
    }

    private func openSystemNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
}
