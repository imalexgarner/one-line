import XCTest
@testable import OneLine

final class MonthLayoutTests: XCTestCase {
    private func calendar(firstWeekday: Int) -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = firstWeekday
        return c
    }
    private func may2026(_ c: Calendar) -> Date { c.date(from: DateComponents(year: 2026, month: 5, day: 1))! }

    func testSundayFirstLeadsWithFiveBlanks() {   // 1 May 2026 is a Friday
        let c = calendar(firstWeekday: 1)
        let cells = MonthLayout.cells(for: may2026(c), calendar: c)
        XCTAssertEqual(cells.count, 42)
        XCTAssertEqual(cells.firstIndex { $0 != nil }, 5)
        XCTAssertEqual(cells.compactMap { $0 }.count, 31)
    }

    func testMondayFirstLeadsWithFourBlanksAndFiveRows() {
        let c = calendar(firstWeekday: 2)
        let cells = MonthLayout.cells(for: may2026(c), calendar: c)
        XCTAssertEqual(cells.count, 35)
        XCTAssertEqual(cells.firstIndex { $0 != nil }, 4)
    }

    func testLeapFebruaryHas29DaysAndStaysMultipleOfSeven() {
        let c = calendar(firstWeekday: 2)
        let feb = c.date(from: DateComponents(year: 2028, month: 2, day: 10))!
        let cells = MonthLayout.cells(for: feb, calendar: c)
        XCTAssertEqual(cells.compactMap { $0 }.count, 29)
        XCTAssertEqual(cells.count % 7, 0)
    }

    func testWeekdaySymbolsRotateWithFirstWeekday() {
        let sun = MonthLayout.weekdaySymbols(calendar: calendar(firstWeekday: 1))
        let mon = MonthLayout.weekdaySymbols(calendar: calendar(firstWeekday: 2))
        XCTAssertEqual(sun.count, 7)
        XCTAssertEqual(Array(sun[1...]) + [sun[0]], mon)
    }

    func testWeeksAreRowsOfSeven() {
        let c = calendar(firstWeekday: 2)
        let rows = MonthLayout.weeks(for: may2026(c), calendar: c)
        XCTAssertEqual(rows.count, 5)
        XCTAssertTrue(rows.allSatisfy { $0.count == 7 })
    }

    func testMonthsRunNewestFirstAndAlwaysIncludeTheCurrentMonth() {
        let c = calendar(firstWeekday: 2)
        let today = c.date(from: DateComponents(year: 2026, month: 5, day: 14))!
        let early = c.date(from: DateComponents(year: 2026, month: 3, day: 20))!
        XCTAssertEqual(MonthLayout.months(from: early, through: today, calendar: c).count, 3)
        XCTAssertEqual(MonthLayout.months(from: today, through: today, calendar: c), [may2026(c)])
    }

    func testARowThatStraddlesTwoMonthsHasADifferentIDInEach() {
        let c = calendar(firstWeekday: 2)
        let sep30 = c.date(from: DateComponents(year: 2026, month: 9, day: 30))!
        let oct1 = c.date(from: DateComponents(year: 2026, month: 10, day: 1))!   // same Mon-first week
        XCTAssertEqual(MonthLayout.rowID(for: sep30, calendar: c), c.date(from: DateComponents(year: 2026, month: 9, day: 28)))
        XCTAssertEqual(MonthLayout.rowID(for: oct1, calendar: c), oct1)
    }
}
