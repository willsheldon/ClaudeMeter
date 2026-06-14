//
//  ChatGPTAppModelTests.swift
//  ClaudeMeterTests
//

import Foundation
import XCTest
@testable import ClaudeMeter

@MainActor
final class ChatGPTAppModelTests: XCTestCase {
    func test_bootstrap_detectsExistingChatGPTSessionWithoutRequiringClaudeSetup() async throws {
        let keychainRepository = KeychainRepositoryFake()
        try await keychainRepository.save(sessionKey: "chatgpt-session-redacted", account: "chatgpt")
        let appModel = makeAppModel(keychainRepository: keychainRepository)

        await appModel.bootstrap()

        XCTAssertTrue(appModel.hasChatGPTSessionCookie)
        XCTAssertFalse(appModel.isSetupComplete)
    }

    func test_validateAndSaveChatGPTSessionCookie_savesToChatGPTAccountAndRefreshesUsage() async throws {
        let expectedUsage = makeChatGPTUsage(percentage: 25)
        let chatGPTService = ChatGPTUsageServiceStub(
            fetchUsageResult: .success(expectedUsage),
            isSessionCookieValid: true
        )
        let keychainRepository = KeychainRepositoryFake()
        let appModel = makeAppModel(
            keychainRepository: keychainRepository,
            chatGPTUsageService: chatGPTService
        )

        let result = try await appModel.validateAndSaveChatGPTSessionCookie("chatgpt-session-redacted")

        XCTAssertTrue(result)
        let savedChatGPTCookie = try await keychainRepository.retrieve(account: "chatgpt")
        XCTAssertEqual(savedChatGPTCookie, "chatgpt-session-redacted")
        await XCTAssertThrowsErrorAsync(try await keychainRepository.retrieve(account: "default"))
        XCTAssertTrue(appModel.hasChatGPTSessionCookie)
        XCTAssertTrue(appModel.settings.isChatGPTUsageShown)
        XCTAssertEqual(appModel.chatGPTUsageData, expectedUsage)
        XCTAssertNil(appModel.chatGPTErrorMessage)
    }

    func test_validateAndSaveChatGPTSessionCookie_withInvalidCookieDoesNotSave() async throws {
        let chatGPTService = ChatGPTUsageServiceStub(isSessionCookieValid: false)
        let keychainRepository = KeychainRepositoryFake()
        let appModel = makeAppModel(
            keychainRepository: keychainRepository,
            chatGPTUsageService: chatGPTService
        )

        let result = try await appModel.validateAndSaveChatGPTSessionCookie("chatgpt-session-redacted")

        XCTAssertFalse(result)
        XCTAssertFalse(appModel.hasChatGPTSessionCookie)
        await XCTAssertThrowsErrorAsync(try await keychainRepository.retrieve(account: "chatgpt"))
    }

    func test_refreshChatGPTUsage_failureDoesNotOverwriteClaudeUsageOrError() async {
        let claudeUsage = makeClaudeUsage(percentage: 42)
        let chatGPTService = ChatGPTUsageServiceStub(
            fetchUsageResult: .failure(ChatGPTUsageError.networkUnavailable)
        )
        let keychainRepository = KeychainRepositoryFake()
        try? await keychainRepository.save(sessionKey: "chatgpt-session-redacted", account: "chatgpt")
        let appModel = makeAppModel(
            keychainRepository: keychainRepository,
            chatGPTUsageService: chatGPTService
        )
        appModel.usageData = claudeUsage
        appModel.errorMessage = "Claude error stays separate"

        await appModel.refreshChatGPTUsage()

        XCTAssertEqual(appModel.usageData, claudeUsage)
        XCTAssertEqual(appModel.errorMessage, "Claude error stays separate")
        XCTAssertEqual(appModel.chatGPTErrorMessage, "ChatGPT quota data is unavailable. Check your connection and try again.")
        XCTAssertNil(appModel.chatGPTUsageData)
    }

    func test_clearChatGPTSessionCookie_deletesOnlyChatGPTAccountAndHidesUsage() async throws {
        let keychainRepository = KeychainRepositoryFake()
        try await keychainRepository.save(sessionKey: TestConstants.sessionKeyValue, account: "default")
        try await keychainRepository.save(sessionKey: "chatgpt-session-redacted", account: "chatgpt")
        let appModel = makeAppModel(keychainRepository: keychainRepository)
        appModel.settings.isChatGPTUsageShown = true
        appModel.chatGPTUsageData = makeChatGPTUsage(percentage: 1)
        appModel.chatGPTErrorMessage = "old error"
        appModel.hasChatGPTSessionCookie = true

        try await appModel.clearChatGPTSessionCookie()

        let savedClaudeKey = try await keychainRepository.retrieve(account: "default")
        XCTAssertEqual(savedClaudeKey, TestConstants.sessionKeyValue)
        await XCTAssertThrowsErrorAsync(try await keychainRepository.retrieve(account: "chatgpt"))
        XCTAssertFalse(appModel.hasChatGPTSessionCookie)
        XCTAssertFalse(appModel.settings.isChatGPTUsageShown)
        XCTAssertNil(appModel.chatGPTUsageData)
        XCTAssertNil(appModel.chatGPTErrorMessage)
    }

    private func makeAppModel(
        keychainRepository: KeychainRepositoryFake = KeychainRepositoryFake(),
        chatGPTUsageService: ChatGPTUsageServiceProtocol = ChatGPTUsageServiceStub()
    ) -> AppModel {
        AppModel(
            settingsRepository: SettingsRepositoryFake(),
            keychainRepository: keychainRepository,
            usageService: UsageServiceStub(fetchUsageResult: .success(makeClaudeUsage(percentage: 10))),
            chatGPTUsageService: chatGPTUsageService,
            notificationService: NotificationServiceSpy()
        )
    }
}

private actor ChatGPTUsageServiceStub: ChatGPTUsageServiceProtocol {
    let fetchUsageResult: Result<ChatGPTUsageData, Error>
    let isSessionCookieValid: Bool

    init(
        fetchUsageResult: Result<ChatGPTUsageData, Error> = .success(makeChatGPTUsage(percentage: 10)),
        isSessionCookieValid: Bool = true
    ) {
        self.fetchUsageResult = fetchUsageResult
        self.isSessionCookieValid = isSessionCookieValid
    }

    func fetchUsage(sessionCookie: String) async throws -> ChatGPTUsageData {
        switch fetchUsageResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    func validateSessionCookie(_ sessionCookie: String) async throws -> Bool {
        isSessionCookieValid
    }
}

private func makeClaudeUsage(percentage: Double) -> UsageData {
    UsageData(
        sessionUsage: UsageLimit(
            utilization: percentage,
            resetAt: Date().addingTimeInterval(3600)
        ),
        weeklyUsage: UsageLimit(
            utilization: 50,
            resetAt: Date().addingTimeInterval(86400)
        ),
        sonnetUsage: nil,
        lastUpdated: Date()
    )
}

private func makeChatGPTUsage(percentage: Double) -> ChatGPTUsageData {
    ChatGPTUsageData(
        rows: [
            .init(label: "Codex Tasks", usedPercent: percentage, resetAt: Date(timeIntervalSince1970: 0))
        ],
        lastUpdated: Date(timeIntervalSince1970: 0)
    )
}

private func XCTAssertThrowsErrorAsync(
    _ expression: @autoclosure () async throws -> some Any,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error", file: file, line: line)
    } catch {
        // Expected
    }
}
