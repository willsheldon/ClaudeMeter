import XCTest
@testable import Pinemeter

final class AppSettingsTests: XCTestCase {
    func test_setRefreshInterval_clampsBelowMinimumToRefreshMinimum() {
        var settings = AppSettings.default

        settings.setRefreshInterval(Constants.Refresh.minimum - 1)

        XCTAssertEqual(settings.refreshInterval, Constants.Refresh.minimum)
    }

    func test_setRefreshInterval_clampsAboveMaximumToRefreshMaximum() {
        var settings = AppSettings.default

        settings.setRefreshInterval(Constants.Refresh.maximum + 1)

        XCTAssertEqual(settings.refreshInterval, Constants.Refresh.maximum)
    }

    func test_setRefreshInterval_keepsInRangeValue() {
        var settings = AppSettings.default
        let inRangeInterval = (Constants.Refresh.minimum + Constants.Refresh.maximum) / 2

        settings.setRefreshInterval(inRangeInterval)

        XCTAssertEqual(settings.refreshInterval, inRangeInterval)
    }
}
