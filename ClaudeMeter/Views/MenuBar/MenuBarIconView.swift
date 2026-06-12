//
//  MenuBarIconView.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import SwiftUI

/// SwiftUI view for menu bar icon with configurable style
struct MenuBarIconView: View {
    let percentage: Double
    let status: UsageStatus
    let isLoading: Bool
    let isStale: Bool
    let iconStyle: IconStyle
    var weeklyPercentage: Double = 0  // Optional, used by dualBar style
    var quotaBars: [MenuBarQuotaBar] = []

    var body: some View {
        switch iconStyle {
        case .battery:
            BatteryIcon(percentage: percentage, status: status, isLoading: isLoading, isStale: isStale)
        case .circular:
            CircularGaugeIcon(percentage: percentage, status: status, isLoading: isLoading, isStale: isStale)
        case .minimal:
            MinimalIcon(percentage: percentage, status: status, isLoading: isLoading, isStale: isStale)
        case .segments:
            SegmentedBarIcon(percentage: percentage, status: status, isLoading: isLoading, isStale: isStale)
        case .dualBar:
            DualBarIcon(
                percentage: percentage,
                status: status,
                isLoading: isLoading,
                isStale: isStale,
                quotaBars: quotaBars.isEmpty
                    ? [
                        MenuBarQuotaBar(label: "Claude 5h", percentage: percentage, status: status),
                        MenuBarQuotaBar(label: "Claude weekly", percentage: weeklyPercentage, status: .safe)
                    ]
                    : quotaBars
            )
        case .gauge:
            GaugeIcon(percentage: percentage, status: status, isLoading: isLoading, isStale: isStale)
        }
    }
}

// MARK: - Preview

#Preview("All Styles") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(IconStyle.allCases) { style in
            HStack {
                Text(style.displayName)
                    .frame(width: 80, alignment: .leading)
                MenuBarIconView(percentage: 65, status: .warning, isLoading: false, isStale: false, iconStyle: style, weeklyPercentage: 45)
            }
        }
    }
    .padding()
}

#Preview("Battery States") {
    VStack(spacing: 20) {
        MenuBarIconView(percentage: 35, status: .safe, isLoading: false, isStale: false, iconStyle: .battery)
        MenuBarIconView(percentage: 65, status: .warning, isLoading: false, isStale: false, iconStyle: .battery)
        MenuBarIconView(percentage: 92, status: .critical, isLoading: false, isStale: false, iconStyle: .battery)
        MenuBarIconView(percentage: 45, status: .safe, isLoading: true, isStale: false, iconStyle: .battery)
        MenuBarIconView(percentage: 45, status: .safe, isLoading: false, isStale: true, iconStyle: .battery)
    }
    .padding()
}
