//
//  UsageAPIResponse.swift
//  Pinemeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// API response for usage data
struct UsageAPIResponse: Codable {
    let fiveHour: UsageLimitResponse
    let sevenDay: UsageLimitResponse
    let sevenDaySonnet: UsageLimitResponse?
    var limits: [ScopedUsageLimitResponse]? = nil

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDaySonnet = "seven_day_sonnet"
        case limits
    }
}

/// Newer Claude usage responses expose model-specific meters in `limits`.
struct ScopedUsageLimitResponse: Codable {
    struct Scope: Codable {
        struct Model: Codable {
            let displayName: String?

            enum CodingKeys: String, CodingKey {
                case displayName = "display_name"
            }
        }

        let model: Model?
    }

    let percent: Double?
    let resetsAt: String?
    let scope: Scope?

    enum CodingKeys: String, CodingKey {
        case percent
        case resetsAt = "resets_at"
        case scope
    }
}

/// Individual usage limit response from API
struct UsageLimitResponse: Codable {
    let utilization: Double // Percentage 0-100
    let resetsAt: String? // ISO8601 string, can be null

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

/// Mapping error for API response conversion
enum MappingError: LocalizedError {
    case invalidDateFormat
    case missingCriticalField(field: String)

    var errorDescription: String? {
        switch self {
        case .invalidDateFormat:
            return "Server returned invalid date format"
        case .missingCriticalField(let field):
            return "Server response missing critical field: \(field)"
        }
    }
}

/// Extension to map API response to domain model
extension UsageAPIResponse {
    func toDomain() throws -> UsageData {
        let sessionResetDate = parseResetDate(
            from: fiveHour.resetsAt,
            fallback: Constants.Pacing.sessionWindow
        )
        let weeklyResetDate = parseResetDate(
            from: sevenDay.resetsAt,
            fallback: Constants.Pacing.weeklyWindow
        )

        // Handle optional sonnet usage
        let sonnetLimit: UsageLimit? = sevenDaySonnet.map { sonnet -> UsageLimit in
            let sonnetResetDate = parseResetDate(
                from: sonnet.resetsAt,
                fallback: Constants.Pacing.weeklyWindow
            )
            return UsageLimit(
                utilization: sonnet.utilization,
                resetAt: sonnetResetDate
            )
        }

        let fableLimit: UsageLimit? = limits?
            .first(where: {
                $0.scope?.model?.displayName?.localizedCaseInsensitiveContains("fable") == true
                    && $0.percent != nil
            })
            .flatMap { fable -> UsageLimit? in
                guard let percent = fable.percent else { return nil }
                let resetDate = parseResetDate(
                    from: fable.resetsAt,
                    fallback: Constants.Pacing.weeklyWindow
                )
                return UsageLimit(utilization: percent, resetAt: resetDate)
            }

        return UsageData(
            sessionUsage: UsageLimit(
                utilization: fiveHour.utilization,
                resetAt: sessionResetDate
            ),
            weeklyUsage: UsageLimit(
                utilization: sevenDay.utilization,
                resetAt: weeklyResetDate
            ),
            sonnetUsage: sonnetLimit,
            fableUsage: fableLimit,
            lastUpdated: Date()
        )
    }

    /// Parses a `resets_at` timestamp leniently: Claude's API has been
    /// observed emitting fractional-second timestamps
    /// ("2025-01-01T00:00:00.000Z"), but a millisecond-free timestamp
    /// ("2025-01-01T00:00:00Z") is an equally spec-legal ISO-8601 variant.
    /// Utilization (the number that matters) must not be lost over a
    /// secondary field's formatting: a missing or unparseable reset
    /// timestamp both fall back to the same synthetic window rather than
    /// failing the whole response (H2).
    private func parseResetDate(from rawValue: String?, fallback: TimeInterval) -> Date {
        guard let rawValue, let date = Self.parseISO8601(rawValue) else {
            return Date().addingTimeInterval(fallback)
        }
        return date
    }

    private static func parseISO8601(_ rawValue: String) -> Date? {
        let withFractionalSeconds = ISO8601DateFormatter()
        withFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractionalSeconds.date(from: rawValue) {
            return date
        }

        let withoutFractionalSeconds = ISO8601DateFormatter()
        withoutFractionalSeconds.formatOptions = [.withInternetDateTime]
        return withoutFractionalSeconds.date(from: rawValue)
    }
}
