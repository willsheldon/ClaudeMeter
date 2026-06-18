import AppKit
import Foundation
import Observation

/// Recovery action that can be shown for a provider credential without exposing credential material.
enum ProviderCredentialActionKind: String, Equatable, Hashable, Sendable {
    case reconnect
    case repair
    case clear

    var displayTitle: String {
        switch self {
        case .reconnect:
            return "Reconnect"
        case .repair:
            return "Repair"
        case .clear:
            return "Clear"
        }
    }
}

/// Sanitized credential status view model for setup/settings surfaces.
struct AppProviderCredentialStatus: Identifiable, Equatable, Sendable {
    struct Action: Identifiable, Equatable, Sendable {
        let kind: ProviderCredentialActionKind

        var id: String { kind.rawValue }
        var displayTitle: String { kind.displayTitle }
    }

    let state: CredentialState
    let actions: [Action]

    var id: String { state.identity.id }
    var provider: CredentialProvider { state.identity.provider }
    var kind: CredentialKind { state.identity.kind }
    var providerName: String { provider.displayName }
    var credentialName: String { state.identity.displayName }
    var statusTitle: String { state.health.displayTitle }
    var statusDescription: String { state.displayDescription }
    var lastFailureTitle: String? { state.failureCategory?.displayTitle }
    var recoverySuggestion: String? { state.recoverySuggestion }

    var searchableText: String {
        [
            providerName,
            credentialName,
            statusTitle,
            statusDescription,
            lastFailureTitle,
            recoverySuggestion,
            actions.map(\.displayTitle).joined(separator: " ")
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
}

/// Main application model for SwiftUI-first architecture.
@MainActor
@Observable
final class AppModel {
    // MARK: - Published State

    var settings: AppSettings = .default {
        didSet {
            guard hasLoadedSettings else { return }
            scheduleSettingsSave(previous: oldValue)
        }
    }

    var usageData: UsageData?
    var chatGPTUsageData: ChatGPTUsageData?
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var isRefreshingChatGPT: Bool = false
    var errorMessage: String?
    var chatGPTErrorMessage: String?
    var isSetupComplete: Bool = false
    var hasChatGPTSessionCookie: Bool = false
    var isReady: Bool = false
    var claudeCredentialState: CredentialState = CredentialState(
        identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
        health: .unknown
    )
    var chatGPTCredentialState: CredentialState = CredentialState(
        identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
        health: .unknown
    )

    var providerCredentialStatuses: [AppProviderCredentialStatus] {
        [
            AppProviderCredentialStatus(
                state: claudeCredentialState,
                actions: credentialActions(for: claudeCredentialState)
            ),
            AppProviderCredentialStatus(
                state: chatGPTCredentialState,
                actions: credentialActions(for: chatGPTCredentialState)
            )
        ]
    }

    // MARK: - Dependencies

    @ObservationIgnored private let settingsRepository: SettingsRepositoryProtocol
    @ObservationIgnored private let keychainRepository: KeychainRepositoryProtocol
    @ObservationIgnored private let usageService: UsageServiceProtocol
    @ObservationIgnored private let chatGPTUsageService: ChatGPTUsageServiceProtocol
    @ObservationIgnored private let chatGPTSessionRepository: any ChatGPTSessionRepositoryProtocol
    @ObservationIgnored private let notificationService: NotificationServiceProtocol
    @ObservationIgnored private let sessionKeyImportService: SessionKeyImportServiceProtocol

    // MARK: - Private

    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var settingsSaveTask: Task<Void, Never>?
    @ObservationIgnored private var wakeTask: Task<Void, Never>?
    @ObservationIgnored private var hasLoadedSettings: Bool = false
    @ObservationIgnored private let refreshClock = ContinuousClock()

    // MARK: - Initialization

    init(
        settingsRepository: SettingsRepositoryProtocol = SettingsRepository(),
        keychainRepository: KeychainRepositoryProtocol = KeychainRepository(),
        usageService: UsageServiceProtocol? = nil,
        chatGPTUsageService: ChatGPTUsageServiceProtocol? = nil,
        chatGPTSessionRepository: (any ChatGPTSessionRepositoryProtocol)? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        sessionKeyImportService: SessionKeyImportServiceProtocol? = nil
    ) {
        self.settingsRepository = settingsRepository
        self.keychainRepository = keychainRepository
        let chatGPTSessionRepository = chatGPTSessionRepository ?? ChatGPTSessionRepository()
        self.chatGPTSessionRepository = chatGPTSessionRepository
        self.sessionKeyImportService = sessionKeyImportService ?? SessionKeyImportService(
            keychainRepository: keychainRepository
        )

        let networkService = WebViewNetworkService(chatGPTSessionRepository: chatGPTSessionRepository)
        let cacheRepository = CacheRepository()
        let usageService = usageService ?? UsageService(
            networkService: networkService,
            cacheRepository: cacheRepository,
            keychainRepository: keychainRepository,
            settingsRepository: settingsRepository
        )
        self.usageService = usageService
        self.chatGPTUsageService = chatGPTUsageService ?? ChatGPTUsageService(sessionRepository: chatGPTSessionRepository)
        self.notificationService = notificationService ?? NotificationService(
            settingsRepository: settingsRepository
        )

        self.notificationService.setupDelegate()
    }

    // MARK: - Lifecycle

    func bootstrap() async {
        guard !isReady else { return }
        settings = await settingsRepository.load()
        hasLoadedSettings = true

        isSetupComplete = await keychainRepository.exists(account: "default")
        claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: isSetupComplete ? .valid : .missing,
            failureCategory: isSetupComplete ? nil : .missing,
            checkedAt: Date()
        )
        let chatGPTStatus = await chatGPTSessionRepository.validate(account: ChatGPTUsageService.defaultSessionAccount)
        hasChatGPTSessionCookie = chatGPTStatus.state == .available
        chatGPTCredentialState = Self.credentialState(from: chatGPTStatus, checkedAt: Date())
        isReady = true

        if hasChatGPTSessionCookie && settings.isChatGPTUsageShown {
            await refreshChatGPTUsage()
        }

        if isSetupComplete {
            await refreshUsage(forceRefresh: true)
        }

        if isSetupComplete || hasChatGPTSessionCookie {
            startRefreshLoop()
        }

        startWakeObserver()
    }

    // MARK: - Usage

    func refreshUsage(forceRefresh: Bool = false) async {
        guard isSetupComplete else {
            usageData = nil
            return
        }
        guard !isRefreshing else { return }

        if usageData == nil {
            isLoading = true
        }
        isRefreshing = true
        errorMessage = nil

        defer {
            isLoading = false
            isRefreshing = false
        }

        do {
            let data = try await usageService.fetchUsage(forceRefresh: forceRefresh)
            usageData = data
            await notificationService.evaluateThresholds(
                usageData: data,
                settings: settings
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - ChatGPT Usage

    func refreshChatGPTUsage() async {
        if !hasChatGPTSessionCookie {
            let status = await chatGPTSessionRepository.validate(account: ChatGPTUsageService.defaultSessionAccount)
            hasChatGPTSessionCookie = status.state == .available
            chatGPTCredentialState = Self.credentialState(from: status, checkedAt: Date())
        }
        guard hasChatGPTSessionCookie else {
            chatGPTUsageData = nil
            return
        }
        guard !isRefreshingChatGPT else { return }

        isRefreshingChatGPT = true
        chatGPTErrorMessage = nil

        defer {
            isRefreshingChatGPT = false
        }

        do {
            chatGPTUsageData = try await chatGPTUsageService.fetchUsage()
            hasChatGPTSessionCookie = true
            chatGPTCredentialState = CredentialState(
                identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
                health: .valid,
                checkedAt: Date()
            )
        } catch ChatGPTUsageError.missingSessionCookie {
            hasChatGPTSessionCookie = false
            chatGPTUsageData = nil
            chatGPTErrorMessage = ChatGPTUsageError.missingSessionCookie.localizedDescription
            chatGPTCredentialState = CredentialState(
                identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
                health: .missing,
                failureCategory: .missing,
                checkedAt: Date()
            )
        } catch ChatGPTUsageError.invalidSessionCookie {
            hasChatGPTSessionCookie = false
            chatGPTUsageData = nil
            chatGPTErrorMessage = ChatGPTUsageError.invalidSessionCookie.localizedDescription
            chatGPTCredentialState = CredentialState(
                identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
                health: .invalid,
                failureCategory: .providerRejected,
                checkedAt: Date()
            )
        } catch {
            chatGPTUsageData = nil
            chatGPTErrorMessage = error.localizedDescription
        }
    }

    func loadChatGPTSessionCookie() async -> String? {
        do {
            return try await chatGPTSessionRepository.load(account: ChatGPTUsageService.defaultSessionAccount).sessionCookie
        } catch {
            return nil
        }
    }

    func validateAndSaveChatGPTSessionCookie(_ rawValue: String) async throws -> Bool {
        let trimmedCookie = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCookie.isEmpty else { return false }

        let isValid = try await chatGPTUsageService.validateSessionCookie(trimmedCookie)
        guard isValid else {
            hasChatGPTSessionCookie = false
            chatGPTCredentialState = CredentialState(
                identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
                health: .invalid,
                failureCategory: .providerRejected,
                checkedAt: Date()
            )
            return false
        }

        try await chatGPTSessionRepository.save(
            ChatGPTSession(sessionCookie: trimmedCookie),
            account: ChatGPTUsageService.defaultSessionAccount
        )
        hasChatGPTSessionCookie = true
        chatGPTCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
            health: .valid,
            checkedAt: Date()
        )
        settings.isChatGPTUsageShown = true
        await refreshChatGPTUsage()
        return true
    }

    func clearChatGPTSessionCookie() async throws {
        try await chatGPTSessionRepository.clear(account: ChatGPTUsageService.defaultSessionAccount)
        hasChatGPTSessionCookie = false
        settings.isChatGPTUsageShown = false
        chatGPTUsageData = nil
        chatGPTErrorMessage = nil
        chatGPTCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
            health: .missing,
            failureCategory: .missing,
            checkedAt: Date()
        )
    }

    // MARK: - Session Key

    func loadSessionKey() async -> String? {
        do {
            return try await keychainRepository.retrieve(account: "default")
        } catch KeychainError.notFound {
            return nil
        } catch {
            return nil
        }
    }

    func validateAndSaveSessionKey(_ rawValue: String) async throws -> Bool {
        let sessionKey = try SessionKey(rawValue)
        let isValid = try await usageService.validateSessionKey(sessionKey)

        guard isValid else {
            claudeCredentialState = CredentialState(
                identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
                health: .invalid,
                failureCategory: .providerRejected,
                checkedAt: Date()
            )
            return false
        }

        let organizations = try await usageService.fetchOrganizations(sessionKey: sessionKey)
        // Prefer organization with chat capability (Claude.ai usage), fall back to first
        guard let chatOrg = organizations.first(where: { $0.hasChatCapability }) ?? organizations.first,
              let orgUUID = chatOrg.organizationUUID else {
            throw AppError.organizationNotFound
        }

        try await keychainRepository.save(sessionKey: sessionKey.value, account: "default")
        claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .valid,
            checkedAt: Date()
        )

        settings.cachedOrganizationId = orgUUID
        settings.isFirstLaunch = false
        isSetupComplete = true

        await refreshUsage(forceRefresh: true)
        startRefreshLoop()

        return true
    }

    func importAndSaveSessionKey() async throws -> ImportedSessionKey {
        let imported = try await sessionKeyImportService.importSessionKey()
        let isValid = try await validateAndSaveSessionKey(imported.value)

        guard isValid else {
            throw SessionKeyImportError.invalidImportedSessionKey
        }

        return imported
    }

    func repairClaudeSessionKey() async -> CredentialState {
        claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .validating,
            checkedAt: Date()
        )

        let repairedState = await sessionKeyImportService.repairSavedSessionKey(account: "default")
        claudeCredentialState = repairedState

        if repairedState.isUsable {
            isSetupComplete = true
            await refreshUsage(forceRefresh: true)
        }

        return repairedState
    }

    func clearSessionKey() async throws {
        try await keychainRepository.delete(account: "default")
        settings.cachedOrganizationId = nil
        settings.isFirstLaunch = true
        isSetupComplete = false
        claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .missing,
            failureCategory: .missing,
            checkedAt: Date()
        )
        usageData = nil
        errorMessage = nil
        refreshTask?.cancel()
    }

    // MARK: - Notifications

    func requestNotificationPermissionIfNeeded() async {
        let hasPermission = await notificationService.checkNotificationPermissions()
        if !hasPermission {
            _ = try? await notificationService.requestAuthorization()
        }
    }

    func checkNotificationPermissions() async -> Bool {
        await notificationService.checkNotificationPermissions()
    }

    func sendTestNotification() async throws {
        try await notificationService.sendThresholdNotification(
            percentage: 85.0,
            threshold: .warning,
            resetTime: Date().addingTimeInterval(3600)
        )
    }

    // MARK: - Private

    private func credentialActions(for state: CredentialState) -> [AppProviderCredentialStatus.Action] {
        let kinds: [ProviderCredentialActionKind]
        switch state.health {
        case .unknown, .missing:
            kinds = [.reconnect]
        case .validating:
            kinds = []
        case .valid, .refreshRecommended:
            kinds = [.reconnect, .clear]
        case .invalid, .expired, .unavailable:
            kinds = [.reconnect, .repair, .clear]
        }
        return kinds.map(AppProviderCredentialStatus.Action.init(kind:))
    }

    private static func credentialState(
        from status: ChatGPTSessionAcquisitionStatus,
        checkedAt: Date
    ) -> CredentialState {
        CredentialState(
            identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
            health: status.state.credentialHealth,
            failureCategory: status.lastErrorCategory?.credentialFailureCategory ?? status.state.defaultFailureCategory,
            checkedAt: checkedAt
        )
    }

    private func scheduleSettingsSave(previous: AppSettings) {
        settingsSaveTask?.cancel()
        settingsSaveTask = Task {
            try? await settingsRepository.save(settings)
        }

        if previous.refreshInterval != settings.refreshInterval {
            startRefreshLoop()
        }
    }

    private func startRefreshLoop() {
        refreshTask?.cancel()
        guard isSetupComplete || hasChatGPTSessionCookie else { return }

        let interval = Duration.seconds(Int(settings.refreshInterval))
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await self.refreshClock.sleep(for: interval)
                if self.isSetupComplete {
                    await self.refreshUsage()
                }
                if self.hasChatGPTSessionCookie && self.settings.isChatGPTUsageShown {
                    await self.refreshChatGPTUsage()
                }
            }
        }
    }

    private func startWakeObserver() {
        wakeTask?.cancel()
        wakeTask = Task { [weak self] in
            guard let self else { return }
            for await _ in NSWorkspace.shared.notificationCenter.notifications(named: NSWorkspace.didWakeNotification) {
                if self.isSetupComplete {
                    await self.refreshUsage(forceRefresh: true)
                }
                if self.hasChatGPTSessionCookie && self.settings.isChatGPTUsageShown {
                    await self.refreshChatGPTUsage()
                }
            }
        }
    }

    // MARK: - Demo Mode

    #if DEBUG
    /// Applies demo state for App Store screenshots.
    /// Skips normal bootstrap and sets state directly.
    func applyDemoState(
        usageData: UsageData?,
        isSetupComplete: Bool,
        errorMessage: String?,
        isLoading: Bool
    ) {
        self.usageData = usageData
        self.isSetupComplete = isSetupComplete
        self.errorMessage = errorMessage
        self.isLoading = isLoading
        self.isReady = true
        self.hasLoadedSettings = true
        // Don't start refresh loop or wake observer in demo mode
    }
    #endif

}
