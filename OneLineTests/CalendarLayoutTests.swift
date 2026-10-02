import XCTest
@testable import OneLine

final class CalendarLayoutTests: XCTestCase {
    private var cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }()
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date { cal.date(from: DateComponents(year: y, month: m, day: d))! }

    /// April and May 2026, today Thursday 14 May, Monday-first.
    private func layout() -> CalendarLayout {
        let today = date(2026, 5, 14)
        return CalendarLayout(months: MonthLayout.months(from: date(2026, 4, 20), through: today, calendar: cal),
                              today: today, calendar: cal)
    }

    func testFutureRowsAreLeftOut() {
        let l = layout()
        XCTAssertEqual(l.months.map(\.rows.count), [3, 5])   // May stops at the week of the 14th
    }

    func testRowsInAMonthSitOneRowPitchApart() {
        let l = layout()
        XCTAssertEqual(l.offsets[date(2026, 5, 1)], 0)        // May's first row, keyed by its first May date
        XCTAssertEqual(l.offsets[date(2026, 5, 4)], 42)
        XCTAssertEqual(l.offsets[date(2026, 5, 11)], 84)
    }

    func testTheNextMonthStartsAfterAHeadingAndGaps() {
        let l = layout()
        // May: 3 rows -> heading 34 + gap 8 + 3 * 42 = 168
        XCTAssertEqual(l.offsets[date(2026, 4, 1)], 168)      // April's first row: Wed 1 Apr, week of 30 Mar
        XCTAssertEqual(l.snapOffsets, l.snapOffsets.sorted())
        XCTAssertEqual(l.snapOffsets.count, 8)
    }

    func testAStraddlingWeekHasARowInEachMonth() {
        let l = layout()
        XCTAssertNotNil(l.offset(for: date(2026, 4, 28), calendar: cal))   // April's last row
        XCTAssertEqual(l.offset(for: date(2026, 5, 1), calendar: cal), 0)  // May's first row
    }

    func testNearestOffsetPicksTheClosestRow() {
        let l = layout()
        XCTAssertEqual(l.nearestOffset(to: 50), 42)
        XCTAssertEqual(l.nearestOffset(to: 70), 84)
        XCTAssertEqual(l.nearestOffset(to: -30), 0)
    }

    func testAHeadingIsExactlyOneRowSlot() {
        XCTAssertEqual(CalendarLayout.headingHeight + CalendarLayout.gap, CalendarLayout.rowPitch)
    }
}
