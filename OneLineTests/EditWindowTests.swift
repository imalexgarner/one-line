import XCTest
@testable import OneLine

final class EditWindowTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)
    private func day(_ d: Int) -> Date { cal.date(from: DateComponents(year: 2026, month: 5, day: d))! }

    func testTodayAndSixDaysBackAreEditable() {
        let now = day(10)
        XCTAssertTrue(EditWindow.isEditable(day(10), now: now, calendar: cal))
        XCTAssertTrue(EditWindow.isEditable(day(4), now: now, calendar: cal))
    }

    func testSevenDaysBackAndOlderAreLocked() {
        XCTAssertFalse(EditWindow.isEditable(day(3), now: day(10), calendar: cal))
        XCTAssertFalse(EditWindow.isEditable(day(1), now: day(10), calendar: cal))
    }

    func testFutureIsNotEditable() {
        XCTAssertFalse(EditWindow.isEditable(day(11), now: day(10), calendar: cal))
    }

    func testTimeOfDayDoesNotMatter() {
        let lateNow = cal.date(byAdding: .hour, value: 23, to: day(10))!
        XCTAssertTrue(EditWindow.isEditable(day(4), now: lateNow, calendar: cal))
    }
}
