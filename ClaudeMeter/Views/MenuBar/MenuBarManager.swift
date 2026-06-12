//
//  MenuBarManager.swift
//  ClaudeMeter
//
//  Created by Edd on 2026-01-14.
//

import AppKit
import Observation
import SwiftUI

/// Manages NSStatusItem and NSPopover presentation.
@MainActor
final class MenuBarManager {
    private let appModel: AppModel
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let iconCache = IconCache()
    private let iconRenderer = MenuBarIconRenderer()
    private var openUsageObserver: NSObjectProtocol?

    init(appModel: AppModel) {
        self.appModel = appModel
    }

    func start() {
        setupStatusItem()
        createPopover()
        observeIconUpdates()
        observeOpenPopoverRequests()

        Task {
            await appModel.bootstrap()
        }
    }

    deinit {
        if let openUsageObserver {
            NotificationCenter.default.removeObserver(openUsageObserver)
        }
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        button.target = self
        button.action = #selector(togglePopover)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.imagePosition = .imageOnly
        button.setAccessibilityLabel("ClaudeMeter")

        updateIcon()
    }

    private func createPopover() {
        let popoverView = MenuBarPopoverView(appModel: appModel) { [weak self] in
            self?.closePopover()
        }
        let hostingController = NSHostingController(rootView: popoverView)

        let popover = NSPopover()
        popover.contentViewController = hostingController
        popover.behavior = .transient
        popover.animates = true

        self.popover = popover
    }

    private func observeOpenPopoverRequests() {
        openUsageObserver = NotificationCenter.default.addObserver(
            forName: .openUsagePopover,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.showPopover()
            }
        }
    }

    // MARK: - Observation

    private func observeIconUpdates() {
        withObservationTracking {
            _ = appModel.usageData
            _ = appModel.chatGPTUsageData
            _ = appModel.isLoading
            _ = appModel.settings.iconStyle
            _ = appModel.settings.isChatGPTUsageShown
            _ = appModel.settings.isSonnetUsageShown
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.updateIcon()
                self.observeIconUpdates()
            }
        }
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }

        let percentage = clamped(appModel.usageData?.sessionUsage.percentage ?? 0)
        let weeklyPercentage = clamped(appModel.usageData?.weeklyUsage.percentage ?? 0)
        let status = appModel.usageData?.primaryStatus ?? .safe
        let isStale = appModel.usageData?.isStale ?? false
        let isLoading = appModel.isLoading
        let style = appModel.settings.iconStyle
        let quotaBars = menuBarQuotaBars()
        let quotaSignature = quotaBars
            .map { "\($0.label):\(Int($0.percentage.rounded())):\($0.status.rawValue)" }
            .joined(separator: "|")

        if let cachedImage = iconCache.get(
            percentage: percentage,
            status: status,
            isLoading: isLoading,
            isStale: isStale,
            iconStyle: style,
            weeklyPercentage: weeklyPercentage,
            quotaSignature: quotaSignature
        ) {
            button.image = cachedImage
            return
        }

        let image = iconRenderer.render(
            percentage: percentage,
            status: status,
            isLoading: isLoading,
            isStale: isStale,
            iconStyle: style,
            weeklyPercentage: weeklyPercentage,
            quotaBars: quotaBars
        )

        iconCache.set(
            image,
            percentage: percentage,
            status: status,
            isLoading: isLoading,
            isStale: isStale,
            iconStyle: style,
            weeklyPercentage: weeklyPercentage,
            quotaSignature: quotaSignature
        )

        button.image = image
    }

    private func menuBarQuotaBars() -> [MenuBarQuotaBar] {
        var bars: [MenuBarQuotaBar] = []

        if let usageData = appModel.usageData {
            bars.append(MenuBarQuotaBar(label: "Claude 5h", percentage: clamped(usageData.sessionUsage.percentage), status: usageData.sessionUsage.status))
            bars.append(MenuBarQuotaBar(label: "Claude weekly", percentage: clamped(usageData.weeklyUsage.percentage), status: usageData.weeklyUsage.status))
        }

        if appModel.settings.isChatGPTUsageShown, let chatGPTUsageData = appModel.chatGPTUsageData {
            let chatGPTBars = chatGPTUsageData.menuBarRows.map { row in
                MenuBarQuotaBar(
                    label: row.menuBarRole?.menuBarLabel ?? row.label,
                    percentage: clamped(row.usedPercent),
                    status: chatGPTStatus(for: row.usedPercent)
                )
            }
            bars.append(contentsOf: chatGPTBars)
        }

        return bars
    }

    private func chatGPTStatus(for percentage: Double) -> UsageStatus {
        switch percentage {
        case 0..<Constants.Thresholds.Status.warningStart:
            return .safe
        case Constants.Thresholds.Status.warningStart..<Constants.Thresholds.Status.criticalStart:
            return .warning
        default:
            return .critical
        }
    }

    private func clamped(_ value: Double) -> Double {
        max(0, min(value, 100))
    }

    // MARK: - Popover Control

    @objc private func togglePopover() {
        guard let popover else { return }
        popover.isShown ? closePopover() : showPopover()
    }

    private func showPopover() {
        guard let button = statusItem?.button, let popover else { return }
        guard !popover.isShown else { return }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closePopover() {
        popover?.performClose(nil)
    }
}
