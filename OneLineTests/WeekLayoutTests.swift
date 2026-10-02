import XCTest
@testable import OneLine

final class WeekLayoutTests: XCTestCase {
    private var cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }()
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date { cal.date(from: DateComponents(year: y, month: m, day: d))! }

    func testNoEntriesStillHasTheCurrentWeek() {
        let today = date(2026, 5, 14)   // Thursday
        let weeks = WeekLayout.weekStarts(from: today, through: today, calendar: cal)
        XCTAssertEqual(weeks, [date(2026, 5, 11)])
    }

    func testWeeksRunNewestFirstBackToTheEarliestEntry() {
        let weeks = WeekLayout.weekStarts(from: date(2026, 4, 29), through: date(2026, 5, 14), calendar: cal)
        XCTAssertEqual(weeks, [date(2026, 5, 11), date(2026, 5, 4), date(2026, 4, 27)])
    }

    func testAnEarliestDateInTheFutureDoesNotExtendPastToday() {
        let weeks = WeekLayout.weekStarts(from: date(2026, 6, 1), through: date(2026, 5, 14), calendar: cal)
        XCTAssertEqual(weeks, [date(2026, 5, 11)])
    }

    func testAWeekHasSevenConsecutiveDays() {
        let days = WeekLayout.days(inWeekStarting: date(2026, 5, 11), calendar: cal)
        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(days.first, date(2026, 5, 11))
        XCTAssertEqual(days.last, date(2026, 5, 17))
    }

    func testWeekStartHonoursFirstWeekday() {
        XCTAssertEqual(WeekLayout.weekStart(of: date(2026, 5, 17), calendar: cal), date(2026, 5, 11))   // Sunday, Monday-first
    }
}
