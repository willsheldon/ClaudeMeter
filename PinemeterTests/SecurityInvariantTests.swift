import XCTest
@testable import Pinemeter

final class SecurityInvariantTests: XCTestCase {
    private let forbiddenCredentialFragments = [
        "sk-ant-test-synthetic-session-key",
        "__Secure-next-auth.session-token=synthetic-cookie",
        "Cookie:",
        "Bearer synthetic-access-token",
        "access-token-synthetic-secret"
    ]

    func test_appSettingsPersistenceDoesNotEncodeCredentialMaterial() async throws {
        let suiteName = "SecurityInvariantTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        var settings = AppSettings.default
        settings.refreshInterval = 300
        settings.hasNotificationsEnabled = false
        settings.isFirstLaunch = false
        settings.cachedOrganizationId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")
        settings.isSonnetUsageShown = true
        settings.isChatGPTUsageShown = true
        settings.iconStyle = .dualBar
        settings.isColoredIcon = false

        let repository = SettingsRepository(userDefaults: userDefaults)
        try await repository.save(settings)

        let persistedData = try XCTUnwrap(userDefaults.data(forKey: "app_settings"))
        let persistedPayload = try XCTUnwrap(String(data: persistedData, encoding: .utf8))

        let forbiddenPersistenceFragments = [
            "sessionKey",
            "chatGPTSessionCookie",
            "accessToken",
            "__Secure-next-auth",
            "Cookie",
            "Bearer",
            "sk-ant-"
        ]

        for forbiddenFragment in forbiddenPersistenceFragments {
            XCTAssertFalse(
                persistedPayload.contains(forbiddenFragment),
                "AppSettings persistence must not encode credential-bearing fields or values: \(forbiddenFragment)"
            )
        }
    }

    func test_userFacingAppErrorDescriptionsDoNotDiscloseCredentialShapedFragments() {
        let errors: [LocalizedError] = [
            AppError.noSessionKey,
            AppError.networkError(.authenticationFailed),
            AppError.networkError(.httpError(statusCode: 401)),
            AppError.networkError(.decodingFailed(underlyingError: SyntheticCredentialError())),
            AppError.keychainError(.saveFailed(OSStatus: -34018)),
            AppError.keychainError(.updateFailed(OSStatus: -50)),
            AppError.sessionKeyInvalid,
            AppError.apiResponseInvalid,
            AppError.organizationNotFound,
            AppError.cacheCorrupted
        ]

        assertNoCredentialDisclosure(in: errors.map { $0.localizedDescription })
    }

    func test_userFacingChatGPTErrorDescriptionsDoNotDiscloseCredentialShapedFragments() {
        let errors: [LocalizedError] = [
            ChatGPTUsageError.missingSessionCookie,
            ChatGPTUsageError.invalidSessionCookie,
            ChatGPTUsageError.invalidResponse,
            ChatGPTUsageError.httpError(statusCode: 403),
            ChatGPTUsageError.networkUnavailable
        ]

        assertNoCredentialDisclosure(in: errors.map { $0.localizedDescription })
    }

    func test_userFacingNetworkAndKeychainDescriptionsDoNotDiscloseCredentialShapedFragments() {
        let errors: [LocalizedError] = [
            NetworkError.invalidURL,
            NetworkError.invalidResponse,
            NetworkError.authenticationFailed,
            NetworkError.rateLimitExceeded,
            NetworkError.httpError(statusCode: 500),
            NetworkError.decodingFailed(underlyingError: SyntheticCredentialError()),
            NetworkError.networkUnavailable,
            NetworkError.timeout,
            KeychainError.saveFailed(OSStatus: -34018),
            KeychainError.notFound,
            KeychainError.updateFailed(OSStatus: -50),
            KeychainError.deleteFailed(OSStatus: -25300)
        ]

        assertNoCredentialDisclosure(in: errors.map { $0.localizedDescription })
    }

    func test_networkServiceDiagnosticsDoNotLogResponseBodiesOrCredentialFragments() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile.deletingLastPathComponent().deletingLastPathComponent()
        let networkServiceURL = repositoryRoot
            .appendingPathComponent("Pinemeter")
            .appendingPathComponent("Services")
            .appendingPathComponent("NetworkService.swift")
        let source = try String(contentsOf: networkServiceURL, encoding: .utf8)

        let prohibitedBodyLoggingPatterns = [
            "responseBody",
            "Response:",
            "String(data: data"
        ]

        for prohibitedPattern in prohibitedBodyLoggingPatterns {
            XCTAssertFalse(
                source.contains(prohibitedPattern),
                "NetworkService diagnostics must not log or construct response bodies: \(prohibitedPattern)"
            )
        }

        let diagnosticLines = source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { $0.contains("logger.") }
        let prohibitedDiagnosticFragments = [
            "Cookie:",
            "sessionKey",
            "Bearer",
            "responseBody"
        ]

        for diagnosticLine in diagnosticLines {
            for prohibitedFragment in prohibitedDiagnosticFragments {
                XCTAssertFalse(
                    diagnosticLine.contains(prohibitedFragment),
                    "NetworkService diagnostic logs must not include credential-shaped fragments or response bodies: \(prohibitedFragment)"
                )
            }
        }
    }

    private func assertNoCredentialDisclosure(in descriptions: [String], file: StaticString = #filePath, line: UInt = #line) {
        for description in descriptions {
            for forbiddenFragment in forbiddenCredentialFragments {
                XCTAssertFalse(
                    description.contains(forbiddenFragment),
                    "User-facing error descriptions must not include credential-shaped fragments: \(forbiddenFragment)",
                    file: file,
                    line: line
                )
            }
        }
    }
}

private struct SyntheticCredentialError: LocalizedError {
    var errorDescription: String? {
        "Synthetic upstream failure with sk-ant-test-synthetic-session-key, Cookie: __Secure-next-auth.session-token=synthetic-cookie, Bearer synthetic-access-token, access-token-synthetic-secret"
    }
}
