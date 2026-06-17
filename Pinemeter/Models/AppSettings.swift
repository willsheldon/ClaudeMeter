//
//  AppSettings.swift
//  Pinemeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// User preferences and app configuration
struct AppSettings: Codable, Equatable, Sendable {
    /// Refresh interval in seconds (60-600)
    var refreshInterval: TimeInterval

    /// Whether notifications are enabled
    var hasNotificationsEnabled: Bool

    /// Notification thresholds
    var notificationThresholds: NotificationThresholds

    /// Whether this is first launch
    var isFirstLaunch: Bool

    /// Last known organization ID (cached)
    var cachedOrganizationId: UUID?

    /// Whether to show Sonnet usage in the popover
    var isSonnetUsageShown: Bool

    /// Whether to show ChatGPT quota usage in the popover
    var isChatGPTUsageShown: Bool

    /// Menu bar icon display style
    var iconStyle: IconStyle

    /// Whether menu bar icons are shown in color instead of monochrome.
    var isColoredIcon: Bool

    static let `default` = AppSettings(
        refreshInterval: 60,
        hasNotificationsEnabled: true,
        notificationThresholds: .default,
        isFirstLaunch: true,
        cachedOrganizationId: nil,
        isSonnetUsageShown: false,
        isChatGPTUsageShown: false,
        iconStyle: .dualBar,
        isColoredIcon: true
    )

    enum CodingKeys: String, CodingKey {
        case refreshInterval = "refresh_interval"
        case hasNotificationsEnabled = "notifications_enabled"
        case notificationThresholds = "notification_thresholds"
        case isFirstLaunch = "is_first_launch"
        case cachedOrganizationId = "cached_organization_id"
        case isSonnetUsageShown = "show_sonnet_usage"
        case isChatGPTUsageShown = "show_chatgpt_usage"
        case legacyOpenAIUsageShown = "show_openai_usage"
        case iconStyle = "icon_style"
        case isColoredIcon = "is_colored_icon"
    }
}

extension AppSettings {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = AppSettings.default

        refreshInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .refreshInterval) ?? defaults.refreshInterval
        hasNotificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hasNotificationsEnabled) ?? defaults.hasNotificationsEnabled
        notificationThresholds = try container.decodeIfPresent(NotificationThresholds.self, forKey: .notificationThresholds) ?? defaults.notificationThresholds
        isFirstLaunch = try container.decodeIfPresent(Bool.self, forKey: .isFirstLaunch) ?? defaults.isFirstLaunch
        cachedOrganizationId = try container.decodeIfPresent(UUID.self, forKey: .cachedOrganizationId)
        isSonnetUsageShown = try container.decodeIfPresent(Bool.self, forKey: .isSonnetUsageShown) ?? defaults.isSonnetUsageShown
        isChatGPTUsageShown = try container.decodeIfPresent(Bool.self, forKey: .isChatGPTUsageShown)
            ?? container.decodeIfPresent(Bool.self, forKey: .legacyOpenAIUsageShown)
            ?? defaults.isChatGPTUsageShown
        iconStyle = try container.decodeIfPresent(IconStyle.self, forKey: .iconStyle) ?? defaults.iconStyle
        isColoredIcon = try container.decodeIfPresent(Bool.self, forKey: .isColoredIcon) ?? defaults.isColoredIcon
    }

    init(
        refreshInterval: TimeInterval,
        hasNotificationsEnabled: Bool,
        notificationThresholds: NotificationThresholds,
        isFirstLaunch: Bool,
        cachedOrganizationId: UUID?,
        isSonnetUsageShown: Bool,
        isChatGPTUsageShown: Bool,
        iconStyle: IconStyle
    ) {
        self.refreshInterval = refreshInterval
        self.hasNotificationsEnabled = hasNotificationsEnabled
        self.notificationThresholds = notificationThresholds
        self.isFirstLaunch = isFirstLaunch
        self.cachedOrganizationId = cachedOrganizationId
        self.isSonnetUsageShown = isSonnetUsageShown
        self.isChatGPTUsageShown = isChatGPTUsageShown
        self.iconStyle = iconStyle
        self.isColoredIcon = AppSettings.default.isColoredIcon
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(refreshInterval, forKey: .refreshInterval)
        try container.encode(hasNotificationsEnabled, forKey: .hasNotificationsEnabled)
        try container.encode(notificationThresholds, forKey: .notificationThresholds)
        try container.encode(isFirstLaunch, forKey: .isFirstLaunch)
        try container.encodeIfPresent(cachedOrganizationId, forKey: .cachedOrganizationId)
        try container.encode(isSonnetUsageShown, forKey: .isSonnetUsageShown)
        try container.encode(isChatGPTUsageShown, forKey: .isChatGPTUsageShown)
        try container.encode(iconStyle, forKey: .iconStyle)
        try container.encode(isColoredIcon, forKey: .isColoredIcon)
    }
}

extension AppSettings {
    /// Validate refresh interval is within bounds
    mutating func setRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = max(60, min(600, interval))
    }
}
