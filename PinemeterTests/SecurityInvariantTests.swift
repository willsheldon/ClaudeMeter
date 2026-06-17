import XCTest
@testable import Pinemeter

final class SecurityInvariantTests: XCTestCase {
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

        let forbiddenCredentialFragments = [
            "sessionKey",
            "chatGPTSessionCookie",
            "accessToken",
            "__Secure-next-auth",
            "Cookie",
            "Bearer",
            "sk-ant-"
        ]

        for forbiddenFragment in forbiddenCredentialFragments {
            XCTAssertFalse(
                persistedPayload.contains(forbiddenFragment),
                "AppSettings persistence must not encode credential-bearing fields or values: \(forbiddenFragment)"
            )
        }
    }
}
