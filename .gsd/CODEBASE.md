# Codebase Map

Generated: 2026-06-24T20:35:16Z | Files: 117 | Described: 0/117
<!-- gsd:codebase-meta {"generatedAt":"2026-06-24T20:35:16Z","fingerprint":"b8f5e5f61b85eb9109ca7c53369c8cf711c62f17","fileCount":117,"truncated":false} -->

### (root)/
- `.gitignore`
- `AGENTS.md`
- `CHANGELOG.md`
- `CLAUDE.md`
- `LICENSE`
- `README.md`
- `work-to-date.md`

### .github/workflows/
- `.github/workflows/deploy-pages.yml`
- `.github/workflows/release.yml`
- `.github/workflows/test.yml`

### Pinemeter.xcodeproj/
- `Pinemeter.xcodeproj/project.pbxproj`

### Pinemeter.xcodeproj/project.xcworkspace/
- `Pinemeter.xcodeproj/project.xcworkspace/contents.xcworkspacedata`

### Pinemeter.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/
- `Pinemeter.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

### Pinemeter.xcodeproj/xcshareddata/xcschemes/
- `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`

### Pinemeter/App/
- `Pinemeter/App/AppDelegate.swift`
- `Pinemeter/App/AppModel.swift`
- `Pinemeter/App/PinemeterApp.swift`
- `Pinemeter/App/SessionKeyImportPromptCoordinator.swift`

### Pinemeter/Assets.xcassets/
- `Pinemeter/Assets.xcassets/Contents.json`

### Pinemeter/Assets.xcassets/AccentColor.colorset/
- `Pinemeter/Assets.xcassets/AccentColor.colorset/Contents.json`

### Pinemeter/Assets.xcassets/AppIcon.appiconset/
- `Pinemeter/Assets.xcassets/AppIcon.appiconset/Contents.json`

### Pinemeter/Models/
- `Pinemeter/Models/AppSettings.swift`
- `Pinemeter/Models/ChatGPTUsageData.swift`
- `Pinemeter/Models/Constants.swift`
- `Pinemeter/Models/CredentialState.swift`
- `Pinemeter/Models/IconStyle.swift`
- `Pinemeter/Models/NotificationState.swift`
- `Pinemeter/Models/NotificationThresholds.swift`
- `Pinemeter/Models/Organization.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Models/UsageData.swift`
- `Pinemeter/Models/UsageLimit.swift`
- `Pinemeter/Models/UsageStatus.swift`

### Pinemeter/Models/API/
- `Pinemeter/Models/API/ChatGPTAPIResponses.swift`
- `Pinemeter/Models/API/OrganizationListResponse.swift`
- `Pinemeter/Models/API/UsageAPIResponse.swift`

### Pinemeter/Models/Errors/
- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/KeychainError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`

### Pinemeter/Repositories/
- `Pinemeter/Repositories/CacheRepository.swift`
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift`
- `Pinemeter/Repositories/GeminiAPIKeyRepository.swift`
- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Repositories/SettingsRepository.swift`

### Pinemeter/Repositories/Protocols/
- `Pinemeter/Repositories/Protocols/CacheRepositoryProtocol.swift`
- `Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift`
- `Pinemeter/Repositories/Protocols/GeminiAPIKeyRepositoryProtocol.swift`
- `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift`
- `Pinemeter/Repositories/Protocols/SettingsRepositoryProtocol.swift`

### Pinemeter/Resources/
- `Pinemeter/Resources/Info.plist`
- `Pinemeter/Resources/Pinemeter.entitlements`

### Pinemeter/Services/
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Services/CredentialStatusService.swift`
- `Pinemeter/Services/GeminiUsageService.swift`
- `Pinemeter/Services/NetworkService.swift`
- `Pinemeter/Services/NotificationService.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/Services/UsageService.swift`
- `Pinemeter/Services/WebViewNetworkService.swift`

### Pinemeter/Services/Protocols/
- `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`
- `Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift`
- `Pinemeter/Services/Protocols/GeminiUsageServiceProtocol.swift`
- `Pinemeter/Services/Protocols/NetworkServiceProtocol.swift`
- `Pinemeter/Services/Protocols/NotificationServiceProtocol.swift`
- `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift`
- `Pinemeter/Services/Protocols/UsageServiceProtocol.swift`
- `Pinemeter/Services/Protocols/UserNotificationCenterProtocol.swift`

### Pinemeter/Utilities/
- `Pinemeter/Utilities/DemoDataFactory.swift`
- `Pinemeter/Utilities/DemoMode.swift`
- `Pinemeter/Utilities/SystemSettingsOpener.swift`

### Pinemeter/Views/MenuBar/
- `Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift`
- `Pinemeter/Views/MenuBar/IconCache.swift`
- `Pinemeter/Views/MenuBar/MenuBarIconRenderer.swift`
- `Pinemeter/Views/MenuBar/MenuBarIconView.swift`
- `Pinemeter/Views/MenuBar/MenuBarManager.swift`
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsageCardView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`

### Pinemeter/Views/MenuBar/IconStyles/
- `Pinemeter/Views/MenuBar/IconStyles/DualBarIcon.swift`

### Pinemeter/Views/Settings/
- `Pinemeter/Views/Settings/SettingsView.swift`

### Pinemeter/Views/Setup/
- `Pinemeter/Views/Setup/SetupWizardView.swift`

### Pinemeter/Views/Shared/
- `Pinemeter/Views/Shared/CopyableErrorText.swift`

### PinemeterTests/
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/AppSettingsTests.swift`
- `PinemeterTests/CacheRepositoryTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
- `PinemeterTests/ChatGPTSessionRepositoryTests.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`
- `PinemeterTests/CopyableErrorPresentationTests.swift`
- `PinemeterTests/CredentialStateTests.swift`
- `PinemeterTests/CredentialStatusServiceTests.swift`
- `PinemeterTests/GeminiCredentialBoundaryTests.swift`
- `PinemeterTests/GeminiUsageServiceTests.swift`
- `PinemeterTests/KeychainRepositoryTests.swift`
- `PinemeterTests/MenuBarIconRendererTests.swift`
- `PinemeterTests/NotificationServiceTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/SessionKeyTests.swift`
- `PinemeterTests/SettingsRepositoryTests.swift`
- `PinemeterTests/UsageLimitRiskTests.swift`
- `PinemeterTests/UsageServiceTests.swift`

### PinemeterTests/TestDoubles/
- `PinemeterTests/TestDoubles/CacheRepositoryFake.swift`
- `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift`
- `PinemeterTests/TestDoubles/NetworkServiceStub.swift`
- `PinemeterTests/TestDoubles/NotificationCenterSpy.swift`
- `PinemeterTests/TestDoubles/NotificationServiceSpy.swift`
- `PinemeterTests/TestDoubles/SessionKeyImportServiceStub.swift`
- `PinemeterTests/TestDoubles/SettingsRepositoryFake.swift`
- `PinemeterTests/TestDoubles/UsageServiceStub.swift`

### PinemeterTests/TestSupport/
- `PinemeterTests/TestSupport/MenuBarIconSnapshotRenderer.swift`
- `PinemeterTests/TestSupport/TestConstants.swift`
- `PinemeterTests/TestSupport/TestError.swift`

### scripts/
- `scripts/demo.sh`
- `scripts/provider_status_surface_audit.py`
- `scripts/provider_workflow_copy_audit.py`

### site/
- `site/index.html`
