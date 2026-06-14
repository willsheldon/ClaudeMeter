//
//  UsagePopoverView.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import SwiftUI
import AppKit

/// Usage popover view with detailed metrics
struct UsagePopoverView: View {
    @Bindable var appModel: AppModel
    let onRequestClose: (() -> Void)?
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Claude Usage")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                // Refresh button
                Button(action: {
                    Task {
                        await appModel.refreshUsage(forceRefresh: true)
                        if appModel.hasChatGPTSessionCookie && appModel.settings.isChatGPTUsageShown {
                            await appModel.refreshChatGPTUsage()
                        }
                    }
                }) {
                    if appModel.isRefreshing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.plain)
                .disabled(appModel.isRefreshing)
                .help("Refresh usage data")
                .keyboardShortcut("r", modifiers: .command)
            }
            .padding()

            Divider()

            // Error banner
            if let errorMessage = appModel.errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    HStack(spacing: 8) {
                        // Retry button for recoverable errors
                        Button("Retry") {
                            Task {
                                await appModel.refreshUsage(forceRefresh: true)
                            }
                        }
                        .buttonStyle(.bordered)

                        // Update Key button for authentication errors
                        if errorMessage.contains("invalid") || errorMessage.contains("expired") || errorMessage.contains("authentication") {
                            Button("Update Session Key") {
                                openSettingsFront()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))

                Divider()
            }

            // Content
            if appModel.usageData != nil || appModel.chatGPTUsageData != nil || appModel.chatGPTErrorMessage != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if let usageData = appModel.usageData {
                            UsageMetricSection(title: "Claude", icon: "sparkles") {
                                UsageMetricBar(
                                    title: "5-hour limit",
                                    subtitle: "Resets \(usageData.sessionUsage.resetDescription)",
                                    percentage: usageData.sessionUsage.percentage,
                                    status: usageData.sessionUsage.status,
                                    icon: "timer"
                                )

                                UsageMetricBar(
                                    title: "Weekly limit",
                                    subtitle: "Resets \(usageData.weeklyUsage.resetDescription)",
                                    percentage: usageData.weeklyUsage.percentage,
                                    status: usageData.weeklyUsage.status,
                                    icon: "calendar"
                                )

                                if appModel.settings.isSonnetUsageShown, let sonnetUsage = usageData.sonnetUsage {
                                    UsageMetricBar(
                                        title: "Weekly Sonnet",
                                        subtitle: "Resets \(sonnetUsage.resetDescription)",
                                        percentage: sonnetUsage.percentage,
                                        status: sonnetUsage.status,
                                        icon: "waveform.path.ecg"
                                    )
                                }
                            }
                        }

                        if appModel.settings.isChatGPTUsageShown, let chatGPTUsageData = appModel.chatGPTUsageData {
                            UsageMetricSection(title: "ChatGPT", icon: "message.badge.waveform") {
                                ForEach(chatGPTUsageData.rows) { row in
                                    UsageMetricBar(
                                        title: row.label,
                                        subtitle: chatGPTQuotaSubtitle(for: row),
                                        percentage: row.usedPercent,
                                        status: status(for: row),
                                        icon: "circle.hexagongrid"
                                    )
                                }
                            }
                        }

                        if appModel.settings.isChatGPTUsageShown, let chatGPTErrorMessage = appModel.chatGPTErrorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text("ChatGPT: \(chatGPTErrorMessage)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(14)
                }
            } else {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading usage data...")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }

            Divider()

            // Footer with settings button
            HStack {
                Button("Settings") {
                    openSettingsFront()
                }
                .buttonStyle(.plain)
                .keyboardShortcut(",", modifiers: .command)
                .accessibilityLabel("Open settings window")

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("q", modifiers: .command)
                .accessibilityLabel("Quit application")
            }
            .padding()
        }
        .frame(width: 380, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Usage Dashboard")
    }

    private func openSettingsFront() {
        onRequestClose?()
        if let keyWindow = NSApp.keyWindow, keyWindow.level != .normal {
            keyWindow.orderOut(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        openSettings()
    }

    private func chatGPTQuotaSubtitle(for row: ChatGPTUsageData.LimitRow) -> String {
        let resetText = row.resetAt.map { "Resets \($0.formatted(.relative(presentation: .named)))" }
        let sourceText = row.subtitle ?? "WHAM: \(row.sourceLabel)"

        if let resetText {
            return "\(sourceText) • \(resetText)"
        }

        return sourceText
    }

    private func status(for row: ChatGPTUsageData.LimitRow) -> UsageStatus {
        switch row.usedPercent {
        case 0..<Constants.Thresholds.Status.warningStart:
            return .safe
        case Constants.Thresholds.Status.warningStart..<Constants.Thresholds.Status.criticalStart:
            return .warning
        default:
            return .critical
        }
    }
}

private struct UsageMetricSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 8) {
                content
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct UsageMetricBar: View {
    let title: String
    let subtitle: String
    let percentage: Double
    let status: UsageStatus
    let icon: String

    private var clampedPercentage: Double {
        min(max(percentage, 0), 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(status.color)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text("\(Int(percentage.rounded()))%")
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundStyle(status.color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.18))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(status.color)
                        .frame(width: geometry.size.width * (clampedPercentage / 100))
                }
            }
            .frame(height: 8)
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(Int(percentage.rounded())) percent used, \(subtitle)")
    }
}
