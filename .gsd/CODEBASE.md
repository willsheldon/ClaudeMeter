# Codebase Map

Generated: 2026-07-05T19:39:57Z | Files: 130 | Described: 0/130
<!-- gsd:codebase-meta {"generatedAt":"2026-07-05T19:39:57Z","fingerprint":"8fd2c1257bab73b27e26f58b95719adf66027cfa","fileCount":130,"truncated":false} -->

### (root)/
- `.gitignore`
- `AGENTS.md`
- `CHANGELOG.md`
- `CLAUDE.md`
- `CONTRIBUTING.md`
- `LICENSE`
- `README.md`
- `RELEASING.md`
- `SECURITY.md`
- `work-to-date.md`

### .github/ISSUE_TEMPLATE/
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `.github/ISSUE_TEMPLATE/feature_request.yml`

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
- `Pinemeter/Models/ClaudeAccount.swift`
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
- *(21 files: 21 .swift)*

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

### scripts/vm_validation/
- `scripts/vm_validation/pinemeter_vm_probe.sh`
- `scripts/vm_validation/pinemeter_vm_validate.sh`
- `scripts/vm_validation/README.md`

### site/
- `site/index.html`
