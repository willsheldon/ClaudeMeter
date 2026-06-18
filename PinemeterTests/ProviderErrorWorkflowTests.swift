import XCTest
@testable import Pinemeter

final class ProviderErrorWorkflowTests: XCTestCase {
    func test_appError_noSessionKey_usesClaudeSpecificCredentialCopy() {
        XCTAssertEqual(AppError.noSessionKey.errorDescription, "No Claude session key found. Please complete setup.")
        XCTAssertEqual(AppError.noSessionKey.recoveryAction, "Complete Claude Setup")
    }

    func test_appError_sessionKeyInvalid_usesClaudeSpecificCredentialCopy() {
        XCTAssertEqual(AppError.sessionKeyInvalid.errorDescription, "Claude session key is invalid or expired. Please update in settings.")
        XCTAssertEqual(AppError.sessionKeyInvalid.recoveryAction, "Update Claude Session Key")
    }

    func test_networkAuthenticationFailed_usesClaudeSpecificCredentialCopy() {
        XCTAssertEqual(NetworkError.authenticationFailed.errorDescription, "Claude session key is invalid or expired")
    }

    func test_claudeRecoveryCopy_detectsOnlyClaudeCredentialAuthenticationMessages() {
        XCTAssertTrue(ClaudeCredentialRecoveryCopy.shouldShowUpdateButton(for: "Claude session key is invalid or expired"))
        XCTAssertTrue(ClaudeCredentialRecoveryCopy.shouldShowUpdateButton(for: "Claude authentication failed"))

        XCTAssertFalse(ClaudeCredentialRecoveryCopy.shouldShowUpdateButton(for: "ChatGPT session token is invalid"))
        XCTAssertFalse(ClaudeCredentialRecoveryCopy.shouldShowUpdateButton(for: "ChatGPT authentication failed"))
        XCTAssertFalse(ClaudeCredentialRecoveryCopy.shouldShowUpdateButton(for: "Network timeout"))
    }

    func test_claudeRecoveryCopy_usesClaudeSpecificButtonLabel() {
        XCTAssertEqual(ClaudeCredentialRecoveryCopy.updateButtonTitle, "Update Claude Session Key")
    }

    func test_chatGPTUsageErrorsDoNotEchoCookieOrBearerTokenSentinels() {
        let forbiddenFragments = [
            "__Secure-next-auth.session-token=synthetic-cookie-redaction-sentinel",
            "synthetic-cookie-redaction-sentinel",
            "Bearer synthetic-access-token-redaction-sentinel",
            "synthetic-access-token-redaction-sentinel"
        ]
        let descriptions = [
            ChatGPTUsageError.missingSessionCookie.localizedDescription,
            ChatGPTUsageError.invalidSessionCookie.localizedDescription,
            ChatGPTUsageError.invalidResponse.localizedDescription,
            ChatGPTUsageError.httpError(statusCode: 401).localizedDescription,
            ChatGPTUsageError.networkUnavailable.localizedDescription
        ]

        for description in descriptions {
            for forbiddenFragment in forbiddenFragments {
                XCTAssertFalse(
                    description.contains(forbiddenFragment),
                    "ChatGPT user-facing errors must not echo credential material: \(forbiddenFragment)"
                )
            }
        }
    }

    func test_chatGPTInvalidCredentialStatusKeepsRecoveryProviderSpecificAndSanitized() {
        let status = AppProviderCredentialStatus(
            state: CredentialState(
                identity: CredentialIdentity(provider: .chatGPT, kind: .sessionCookie),
                health: .invalid,
                failureCategory: .providerRejected,
                checkedAt: Date(timeIntervalSince1970: 0)
            ),
            actions: [.init(kind: .reconnect), .init(kind: .clear)]
        )

        XCTAssertEqual(status.providerName, "ChatGPT")
        XCTAssertEqual(status.credentialName, "ChatGPT session cookie")
        XCTAssertEqual(status.setupPromptTitle, "Recover ChatGPT session cookie")
        XCTAssertEqual(status.setupPromptDescription, "Update the credential and try again.")
        XCTAssertEqual(status.actions.map { $0.displayTitle }, ["Reconnect", "Clear"])
        XCTAssertTrue(status.setupAccessibilityLabel.contains("ChatGPT session cookie status: Invalid"))
        XCTAssertFalse(status.setupAccessibilityLabel.contains("synthetic-chatgpt-session-cookie"))
    }

    func test_credentialRecoverySetupCopyDoesNotExposeRawCredentialMaterial() {
        let status = AppProviderCredentialStatus(
            state: CredentialState(
                identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
                health: .unavailable,
                failureCategory: .storageUnavailable,
                checkedAt: Date(timeIntervalSince1970: 0)
            ),
            actions: [.init(kind: .reconnect), .init(kind: .repair), .init(kind: .clear)]
        )

        XCTAssertEqual(status.setupPromptTitle, "Recover Claude session key")
        XCTAssertEqual(status.setupPromptDescription, "Check Keychain access and try again.")
        XCTAssertTrue(status.setupAccessibilityLabel.contains("Claude session key status: Unavailable"))
        XCTAssertFalse(status.setupAccessibilityLabel.contains("sk-ant-"))
    }

}
