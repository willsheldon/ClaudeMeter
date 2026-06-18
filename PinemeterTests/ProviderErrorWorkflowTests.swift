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
}
