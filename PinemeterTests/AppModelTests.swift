import XCTest
@testable import Pinemeter

@MainActor
final class AppModelTests: XCTestCase {
    func test_bootstrap_withoutSessionKey_showsSetupState() async {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        try? await keychainRepository.delete(account: "default")

        await appModel.bootstrap()

        XCTAssertTrue(appModel.isReady)
        XCTAssertFalse(appModel.isSetupComplete)
        XCTAssertNil(appModel.usageData)
        XCTAssertNil(appModel.errorMessage)
    }

    func test_userWithSessionKey_seesUsageAfterLaunch() async {
        let expectedUsage = makeUsageData(percentage: TestConstants.sessionPercentage)
        let usageService = UsageServiceStub(fetchUsageResult: .success(expectedUsage))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        try? await keychainRepository.save(
            sessionKey: TestConstants.sessionKeyValue,
            account: "default"
        )

        await appModel.bootstrap()

        XCTAssertTrue(appModel.isReady)
        XCTAssertTrue(appModel.isSetupComplete)
        XCTAssertEqual(appModel.usageData, expectedUsage)
        XCTAssertNil(appModel.errorMessage)
        XCTAssertEqual(notificationService.lastEvaluatedUsageData, expectedUsage)
    }

    func test_userWithSessionKey_seesErrorWhenUsageFailsAfterLaunch() async {
        let failure = TestError(message: TestConstants.fetchFailureMessage)
        let usageService = UsageServiceStub(fetchUsageResult: .failure(failure))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        try? await keychainRepository.save(
            sessionKey: TestConstants.sessionKeyValue,
            account: "default"
        )

        await appModel.bootstrap()

        XCTAssertTrue(appModel.isReady)
        XCTAssertTrue(appModel.isSetupComplete)
        XCTAssertNil(appModel.usageData)
        XCTAssertEqual(appModel.errorMessage, failure.localizedDescription)
        XCTAssertNil(notificationService.lastEvaluatedUsageData)
    }

    func test_refreshingUsage_showsLatestUsageAndClearsError() async {
        let expectedUsage = makeUsageData(percentage: TestConstants.sessionPercentage)
        let usageService = UsageServiceStub(fetchUsageResult: .success(expectedUsage))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        appModel.isSetupComplete = true
        appModel.errorMessage = TestConstants.previousErrorMessage

        await appModel.refreshUsage(forceRefresh: true)

        XCTAssertEqual(appModel.usageData, expectedUsage)
        XCTAssertNil(appModel.errorMessage)
        XCTAssertFalse(appModel.isRefreshing)
        XCTAssertFalse(appModel.isLoading)
        XCTAssertEqual(notificationService.lastEvaluatedUsageData, expectedUsage)
    }

    func test_refreshingUsage_showsErrorWhenFetchFails() async {
        let failure = TestError(message: TestConstants.fetchFailureMessage)
        let usageService = UsageServiceStub(fetchUsageResult: .failure(failure))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        appModel.isSetupComplete = true

        await appModel.refreshUsage(forceRefresh: false)

        XCTAssertNil(appModel.usageData)
        XCTAssertEqual(appModel.errorMessage, failure.localizedDescription)
        XCTAssertFalse(appModel.isRefreshing)
        XCTAssertFalse(appModel.isLoading)
        XCTAssertNil(notificationService.lastEvaluatedUsageData)
    }

    func test_refreshingUsage_hidesUsageWhenSetupIncomplete() async {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        appModel.isSetupComplete = false
        appModel.usageData = makeUsageData(percentage: TestConstants.cachedPercentage)

        await appModel.refreshUsage(forceRefresh: false)

        XCTAssertNil(appModel.usageData)
        XCTAssertNil(notificationService.lastEvaluatedUsageData)
    }

    func test_userWithInvalidSessionKey_staysInSetup() async throws {
        let usageService = UsageServiceStub(
            fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)),
            isSessionKeyValid: false
        )
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        let result = try await appModel.validateAndSaveSessionKey(TestConstants.sessionKeyValue)

        XCTAssertFalse(result)
        XCTAssertFalse(appModel.isSetupComplete)
        XCTAssertTrue(appModel.settings.isFirstLaunch)
        XCTAssertNil(appModel.settings.cachedOrganizationId)
        XCTAssertNil(appModel.usageData)
        XCTAssertEqual(appModel.claudeCredentialState.health, .invalid)
        XCTAssertEqual(appModel.claudeCredentialState.failureCategory, .providerRejected)
    }

    func test_providerCredentialStatusViewModelsExposeSanitizedClaudeAndChatGPTState() async throws {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: "raw sk-ant-secret must not appear")))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )
        appModel.claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .unavailable,
            failureCategory: .storageUnavailable,
            checkedAt: Date(timeIntervalSince1970: 0)
        )

        let statuses = appModel.providerCredentialStatuses

        XCTAssertEqual(statuses.map(\.id), ["claude.sessionKey", "chatGPT.sessionCookie"])
        let claude = try XCTUnwrap(statuses.first { $0.provider == .claude })
        XCTAssertEqual(claude.statusTitle, "Unavailable")
        XCTAssertEqual(claude.lastFailureTitle, "Credential storage unavailable")
        XCTAssertEqual(claude.actions.map(\.kind), [.reconnect, .repair, .clear])
        XCTAssertFalse(claude.searchableText.contains("sk-ant-secret"))

        let chatGPT = try XCTUnwrap(statuses.first { $0.provider == .chatGPT })
        XCTAssertEqual(chatGPT.statusTitle, "Unknown")
        XCTAssertEqual(chatGPT.actions.map(\.kind), [.reconnect])
    }

    func test_providerCredentialStatusSetupPromptsDistinguishReadyMissingAndRepairableCredentials() throws {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        appModel.claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .valid,
            checkedAt: Date(timeIntervalSince1970: 0)
        )
        var claude = try XCTUnwrap(appModel.providerCredentialStatuses.first { $0.provider == .claude })
        XCTAssertFalse(claude.shouldPromptForSetupCredential)
        XCTAssertFalse(claude.isRepairableInSetup)
        XCTAssertEqual(claude.setupPromptTitle, "Saved Claude session key is ready")
        XCTAssertTrue(claude.setupAccessibilityLabel.contains("Claude session key status: Ready"))

        appModel.claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .missing,
            failureCategory: .missing,
            checkedAt: Date(timeIntervalSince1970: 0)
        )
        claude = try XCTUnwrap(appModel.providerCredentialStatuses.first { $0.provider == .claude })
        XCTAssertTrue(claude.shouldPromptForSetupCredential)
        XCTAssertFalse(claude.isRepairableInSetup)
        XCTAssertEqual(claude.setupPromptTitle, "Set up Claude session key")

        appModel.claudeCredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .unavailable,
            failureCategory: .storageUnavailable,
            checkedAt: Date(timeIntervalSince1970: 0)
        )
        claude = try XCTUnwrap(appModel.providerCredentialStatuses.first { $0.provider == .claude })
        XCTAssertFalse(claude.shouldPromptForSetupCredential)
        XCTAssertTrue(claude.isRepairableInSetup)
        XCTAssertEqual(claude.setupPromptTitle, "Recover Claude session key")
        XCTAssertFalse(claude.setupAccessibilityLabel.contains(TestConstants.sessionKeyValue))
    }

    func test_providerCredentialStatusesExposeRecoveryActionsForBoundaryStates() throws {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        let cases: [(CredentialHealthState, [ProviderCredentialActionKind])] = [
            (.unknown, [.reconnect]),
            (.missing, [.reconnect]),
            (.validating, []),
            (.valid, [.reconnect, .clear]),
            (.refreshRecommended, [.reconnect, .clear]),
            (.invalid, [.reconnect, .repair, .clear]),
            (.expired, [.reconnect, .repair, .clear]),
            (.unavailable, [.reconnect, .repair, .clear])
        ]

        for (health, expectedActions) in cases {
            appModel.claudeCredentialState = CredentialState(
                identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
                health: health,
                failureCategory: health == .valid ? nil : .providerRejected,
                checkedAt: Date(timeIntervalSince1970: 0)
            )

            let claude = try XCTUnwrap(appModel.providerCredentialStatuses.first { $0.provider == .claude })
            XCTAssertEqual(claude.actions.map(\.kind), expectedActions, "Unexpected actions for \\(health)")
            XCTAssertFalse(claude.searchableText.contains(TestConstants.sessionKeyValue))
        }
    }

    func test_userWithValidSessionKey_entersUsageAndLoadsData() async throws {
        let expectedUsage = makeUsageData(percentage: TestConstants.sessionPercentage)
        let organization = Organization(
            id: 1,
            uuid: TestConstants.organizationUUIDString,
            name: "Test Org",
            capabilities: ["chat"]
        )
        let usageService = UsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            organizations: [organization],
            isSessionKeyValid: true
        )
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        let result = try await appModel.validateAndSaveSessionKey(TestConstants.sessionKeyValue)

        XCTAssertTrue(result)
        XCTAssertTrue(appModel.isSetupComplete)
        XCTAssertFalse(appModel.settings.isFirstLaunch)
        XCTAssertEqual(
            appModel.settings.cachedOrganizationId,
            UUID(uuidString: TestConstants.organizationUUIDString)
        )
        XCTAssertEqual(appModel.usageData, expectedUsage)
    }

    func test_importingSessionKey_savesImportedKeyAndLoadsData() async throws {
        let expectedUsage = makeUsageData(percentage: TestConstants.sessionPercentage)
        let organization = Organization(
            id: 1,
            uuid: TestConstants.organizationUUIDString,
            name: "Test Org",
            capabilities: ["chat"]
        )
        let usageService = UsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            organizations: [organization],
            isSessionKeyValid: true
        )
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        let importService = SessionKeyImportServiceStub(result: .success(ImportedSessionKey(
            value: TestConstants.sessionKeyValue,
            sourceDescription: "Chrome Default"
        )))

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService,
            sessionKeyImportService: importService
        )

        let imported = try await appModel.importAndSaveSessionKey()
        let savedKey = try await keychainRepository.retrieve(account: "default")

        XCTAssertEqual(imported.sourceDescription, "Chrome Default")
        XCTAssertEqual(savedKey, TestConstants.sessionKeyValue)
        XCTAssertTrue(appModel.isSetupComplete)
        XCTAssertEqual(appModel.usageData, expectedUsage)
    }

    func test_repairingClaudeSessionKey_resavesCurrentKeyAndRefreshesCredentialState() async throws {
        let expectedUsage = makeUsageData(percentage: TestConstants.sessionPercentage)
        let usageService = UsageServiceStub(fetchUsageResult: .success(expectedUsage))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        try await keychainRepository.save(sessionKey: TestConstants.sessionKeyValue, account: "default")

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )
        appModel.isSetupComplete = true

        let state = await appModel.repairClaudeSessionKey()
        let savedKey = try await keychainRepository.retrieve(account: "default")

        XCTAssertEqual(state.health, .valid)
        XCTAssertNil(state.failureCategory)
        XCTAssertEqual(appModel.claudeCredentialState, state)
        XCTAssertEqual(savedKey, TestConstants.sessionKeyValue)
        XCTAssertEqual(appModel.usageData, expectedUsage)
    }

    func test_repairingClaudeSessionKey_whenKeychainSaveFailsPublishesSanitizedStorageFailure() async throws {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = RepairFailingKeychainRepository(sessionKey: TestConstants.sessionKeyValue)

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )
        appModel.isSetupComplete = true

        let state = await appModel.repairClaudeSessionKey()

        XCTAssertEqual(state.health, .unavailable)
        XCTAssertEqual(state.failureCategory, .storageUnavailable)
        XCTAssertEqual(appModel.claudeCredentialState, state)
        XCTAssertNil(appModel.usageData)
        XCTAssertNil(appModel.errorMessage)
    }

    func test_importingSessionKey_whenImportedKeyInvalid_staysInSetup() async throws {
        let usageService = UsageServiceStub(
            fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)),
            organizations: [],
            isSessionKeyValid: false
        )
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        let importService = SessionKeyImportServiceStub(result: .success(ImportedSessionKey(
            value: TestConstants.sessionKeyValue,
            sourceDescription: "Chrome Default"
        )))

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService,
            sessionKeyImportService: importService
        )

        do {
            _ = try await appModel.importAndSaveSessionKey()
            XCTFail("Expected invalidImportedSessionKey to be thrown")
        } catch SessionKeyImportError.invalidImportedSessionKey {
            XCTAssertFalse(appModel.isSetupComplete)
            XCTAssertNil(appModel.usageData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_userWithValidSessionKeyWithoutOrganization_staysInSetup() async {
        let usageService = UsageServiceStub(
            fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)),
            organizations: [],
            isSessionKeyValid: true
        )
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        do {
            _ = try await appModel.validateAndSaveSessionKey(TestConstants.sessionKeyValue)
            XCTFail("Expected organizationNotFound to be thrown")
        } catch AppError.organizationNotFound {
            XCTAssertFalse(appModel.isSetupComplete)
            XCTAssertNil(appModel.usageData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_userClearsSession_returnsToSetupState() async throws {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        appModel.isSetupComplete = true
        appModel.usageData = makeUsageData(percentage: TestConstants.cachedPercentage)
        appModel.errorMessage = TestConstants.fetchFailureMessage

        var updatedSettings = appModel.settings
        updatedSettings.cachedOrganizationId = UUID(uuidString: TestConstants.organizationUUIDString)
        updatedSettings.isFirstLaunch = false
        appModel.settings = updatedSettings

        try await appModel.clearSessionKey()

        XCTAssertFalse(appModel.isSetupComplete)
        XCTAssertNil(appModel.usageData)
        XCTAssertNil(appModel.errorMessage)
        XCTAssertNil(appModel.settings.cachedOrganizationId)
        XCTAssertTrue(appModel.settings.isFirstLaunch)
    }

    func test_claudeCredentialLifecycle_recoversFromInvalidClearAndReacquire() async throws {
        let expectedUsage = makeUsageData(percentage: TestConstants.sessionPercentage)
        let organization = Organization(
            id: 1,
            uuid: TestConstants.organizationUUIDString,
            name: "Lifecycle Org",
            capabilities: ["chat"]
        )
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        let invalidUsageService = UsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            organizations: [organization],
            isSessionKeyValid: false
        )
        let invalidModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: invalidUsageService,
            notificationService: notificationService
        )

        let rejected = try await invalidModel.validateAndSaveSessionKey(TestConstants.sessionKeyValue)

        XCTAssertFalse(rejected)
        XCTAssertFalse(invalidModel.isSetupComplete)
        XCTAssertEqual(invalidModel.claudeCredentialState.health, .invalid)
        XCTAssertEqual(invalidModel.claudeCredentialState.failureCategory, .providerRejected)
        do {
            _ = try await keychainRepository.retrieve(account: "default")
            XCTFail("Expected missing Claude session key after invalid validation")
        } catch KeychainError.notFound {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let validUsageService = UsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            organizations: [organization],
            isSessionKeyValid: true
        )
        let setupModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: validUsageService,
            notificationService: notificationService
        )

        let acquired = try await setupModel.validateAndSaveSessionKey(TestConstants.sessionKeyValue)

        let savedSessionKey = try await keychainRepository.retrieve(account: "default")

        XCTAssertTrue(acquired)
        XCTAssertTrue(setupModel.isSetupComplete)
        XCTAssertEqual(setupModel.claudeCredentialState.health, .valid)
        XCTAssertEqual(savedSessionKey, TestConstants.sessionKeyValue)

        let reuseModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: validUsageService,
            notificationService: notificationService
        )

        await reuseModel.bootstrap()

        XCTAssertTrue(reuseModel.isSetupComplete)
        XCTAssertEqual(reuseModel.claudeCredentialState.health, .valid)
        XCTAssertEqual(reuseModel.usageData, expectedUsage)

        try await setupModel.clearSessionKey()

        XCTAssertFalse(setupModel.isSetupComplete)
        XCTAssertNil(setupModel.usageData)
        XCTAssertEqual(setupModel.claudeCredentialState.health, .missing)
        XCTAssertEqual(setupModel.claudeCredentialState.failureCategory, .missing)

        let reacquired = try await setupModel.validateAndSaveSessionKey(TestConstants.sessionKeyValue)

        let reacquiredSessionKey = try await keychainRepository.retrieve(account: "default")

        XCTAssertTrue(reacquired)
        XCTAssertTrue(setupModel.isSetupComplete)
        XCTAssertEqual(setupModel.claudeCredentialState.health, .valid)
        XCTAssertEqual(reacquiredSessionKey, TestConstants.sessionKeyValue)
    }

    func test_chatGPTCredentialLifecycle_recoversFromInvalidClearAndReacquire() async throws {
        let expectedUsage = ChatGPTUsageData(
            rows: [.init(label: "Codex Tasks", usedPercent: 24, resetAt: nil)],
            lastUpdated: Date(timeIntervalSince1970: 0)
        )
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()
        let notificationService = NotificationServiceSpy()
        let chatGPTSessionRepository = AppModelChatGPTSessionRepositoryFake()
        let invalidChatGPTUsageService = AppModelChatGPTUsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            validateResult: false
        )
        let invalidModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage))),
            chatGPTUsageService: invalidChatGPTUsageService,
            chatGPTSessionRepository: chatGPTSessionRepository,
            notificationService: notificationService
        )

        let rejected = try await invalidModel.validateAndSaveChatGPTSessionCookie("synthetic-chatgpt-session-cookie")

        XCTAssertFalse(rejected)
        XCTAssertFalse(invalidModel.hasChatGPTSessionCookie)
        XCTAssertEqual(invalidModel.chatGPTCredentialState.health, .invalid)
        XCTAssertEqual(invalidModel.chatGPTCredentialState.failureCategory, .providerRejected)
        do {
            _ = try await chatGPTSessionRepository.load(account: ChatGPTUsageService.defaultSessionAccount)
            XCTFail("Expected missing ChatGPT session after invalid validation")
        } catch ChatGPTSessionRepositoryError.notFound {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let validChatGPTUsageService = AppModelChatGPTUsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            validateResult: true
        )
        let setupModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage))),
            chatGPTUsageService: validChatGPTUsageService,
            chatGPTSessionRepository: chatGPTSessionRepository,
            notificationService: notificationService
        )

        let acquired = try await setupModel.validateAndSaveChatGPTSessionCookie("synthetic-chatgpt-session-cookie")

        XCTAssertTrue(acquired)
        XCTAssertTrue(setupModel.hasChatGPTSessionCookie)
        XCTAssertTrue(setupModel.settings.isChatGPTUsageShown)
        let savedChatGPTSession = try await chatGPTSessionRepository.load(account: ChatGPTUsageService.defaultSessionAccount)

        XCTAssertEqual(setupModel.chatGPTCredentialState.health, .valid)
        XCTAssertEqual(setupModel.chatGPTUsageData, expectedUsage)
        XCTAssertEqual(savedChatGPTSession.sessionCookie, "synthetic-chatgpt-session-cookie")

        var reuseSettings = AppSettings.default
        reuseSettings.isChatGPTUsageShown = true
        try await settingsRepository.save(reuseSettings)
        let reuseModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage))),
            chatGPTUsageService: validChatGPTUsageService,
            chatGPTSessionRepository: chatGPTSessionRepository,
            notificationService: notificationService
        )

        await reuseModel.bootstrap()

        XCTAssertTrue(reuseModel.hasChatGPTSessionCookie)
        XCTAssertEqual(reuseModel.chatGPTCredentialState.health, .valid)
        XCTAssertEqual(reuseModel.chatGPTUsageData, expectedUsage)

        try await setupModel.clearChatGPTSessionCookie()

        XCTAssertFalse(setupModel.hasChatGPTSessionCookie)
        XCTAssertFalse(setupModel.settings.isChatGPTUsageShown)
        XCTAssertNil(setupModel.chatGPTUsageData)
        XCTAssertNil(setupModel.chatGPTErrorMessage)
        XCTAssertEqual(setupModel.chatGPTCredentialState.health, .missing)
        XCTAssertEqual(setupModel.chatGPTCredentialState.failureCategory, .missing)

        let reacquired = try await setupModel.validateAndSaveChatGPTSessionCookie("synthetic-chatgpt-session-cookie")

        XCTAssertTrue(reacquired)
        XCTAssertTrue(setupModel.hasChatGPTSessionCookie)
        XCTAssertEqual(setupModel.chatGPTCredentialState.health, .valid)
        XCTAssertEqual(setupModel.chatGPTUsageData, expectedUsage)
    }

    func test_userWithNotificationPermission_doesNotSeePermissionPrompt() async {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        notificationService.hasPermission = true
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        await appModel.requestNotificationPermissionIfNeeded()

        XCTAssertEqual(notificationService.requestAuthorizationCallCount, 0)
    }

    func test_userWithoutNotificationPermission_isPromptedForPermission() async {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        notificationService.hasPermission = false
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        await appModel.requestNotificationPermissionIfNeeded()

        XCTAssertEqual(notificationService.requestAuthorizationCallCount, 1)
    }

    func test_userSendsTestNotification_triggersNotificationService() async throws {
        let usageService = UsageServiceStub(fetchUsageResult: .failure(TestError(message: TestConstants.unexpectedErrorMessage)))
        let notificationService = NotificationServiceSpy()
        let settingsRepository = SettingsRepositoryFake()
        let keychainRepository = KeychainRepositoryFake()

        let appModel = AppModel(
            settingsRepository: settingsRepository,
            keychainRepository: keychainRepository,
            usageService: usageService,
            notificationService: notificationService
        )

        try await appModel.sendTestNotification()

        XCTAssertEqual(notificationService.sentThresholdType, .warning)
        XCTAssertEqual(notificationService.sentThresholdPercentage, 85.0)
    }
}

// MARK: - Helpers

private actor RepairFailingKeychainRepository: KeychainRepositoryProtocol {
    private let sessionKey: String

    init(sessionKey: String) {
        self.sessionKey = sessionKey
    }

    func save(sessionKey: String, account: String) async throws {
        throw KeychainError.saveFailed(OSStatus: OSStatus(errSecInteractionNotAllowed))
    }

    func retrieve(account: String) async throws -> String {
        sessionKey
    }

    func repairClaudeSessionKey(_ sessionKey: String, account: String) async throws -> ClaudeCredentialRepairResult {
        throw KeychainError.saveFailed(OSStatus: OSStatus(errSecInteractionNotAllowed))
    }

    func update(sessionKey: String, account: String) async throws {
        throw KeychainError.updateFailed(OSStatus: OSStatus(errSecInteractionNotAllowed))
    }

    func delete(account: String) async throws {}

    func exists(account: String) async -> Bool {
        true
    }
}

private actor AppModelChatGPTUsageServiceStub: ChatGPTUsageServiceProtocol {
    private let fetchUsageResult: Result<ChatGPTUsageData, Error>
    private let validateResult: Bool

    init(fetchUsageResult: Result<ChatGPTUsageData, Error>, validateResult: Bool) {
        self.fetchUsageResult = fetchUsageResult
        self.validateResult = validateResult
    }

    func fetchUsage() async throws -> ChatGPTUsageData {
        switch fetchUsageResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    func fetchUsage(sessionCookie: String) async throws -> ChatGPTUsageData {
        try await fetchUsage()
    }

    func validateSessionCookie(_ sessionCookie: String) async throws -> Bool {
        validateResult
    }
}

private actor AppModelChatGPTSessionRepositoryFake: ChatGPTSessionRepositoryProtocol {
    private var sessions: [String: ChatGPTSession] = [:]
    private var status = ChatGPTSessionAcquisitionStatus(state: .missing, lastErrorCategory: .notFound)

    func save(_ session: ChatGPTSession, account: String) async throws {
        sessions[account] = session
        status = ChatGPTSessionAcquisitionStatus(state: .available, lastErrorCategory: nil)
    }

    func load(account: String) async throws -> ChatGPTSession {
        guard let session = sessions[account] else {
            status = ChatGPTSessionAcquisitionStatus(state: .missing, lastErrorCategory: .notFound)
            throw ChatGPTSessionRepositoryError.notFound
        }
        return session
    }

    func validate(account: String) async -> ChatGPTSessionAcquisitionStatus {
        status
    }

    func clear(account: String) async throws {
        sessions[account] = nil
        status = ChatGPTSessionAcquisitionStatus(state: .missing, lastErrorCategory: .notFound)
    }
}

private func makeUsageData(percentage: Double) -> UsageData {
    let resetDate = Date().addingTimeInterval(TestConstants.oneHourInterval)
    let sessionUsage = UsageLimit(utilization: percentage, resetAt: resetDate)
    let weeklyUsage = UsageLimit(utilization: TestConstants.weeklyPercentage, resetAt: resetDate)

    return UsageData(
        sessionUsage: sessionUsage,
        weeklyUsage: weeklyUsage,
        sonnetUsage: nil,
        lastUpdated: Date()
    )
}
