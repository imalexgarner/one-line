import XCTest
@testable import OneLine

final class ResurfacingTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)
    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date { cal.date(from: DateComponents(year: y, month: m, day: d))! }
    private func entry(_ d: Date, _ t: String = "x") -> Entry { Entry(day: d, text: t, mood: .calm) }

    func testNoPastEntriesReturnsNil() {
        XCTAssertNil(Resurfacing.pick(for: day(2026, 5, 1), from: [entry(day(2026, 5, 1))], calendar: cal))
    }

    func testPrefersSameDayLastYear() {
        let entries = [entry(day(2025, 5, 1), "last year"), entry(day(2026, 4, 1), "month ago")]
        let r = Resurfacing.pick(for: day(2026, 5, 1), from: entries, calendar: cal)
        XCTAssertEqual(r?.entry.text, "last year")
        XCTAssertEqual(r?.label, "1 year ago today")
    }

    func testFallsBackToMonthThenWeek() {
        let m = Resurfacing.pick(for: day(2026, 5, 1), from: [entry(day(2026, 4, 1), "m"), entry(day(2026, 4, 24), "w")], calendar: cal)
        XCTAssertEqual(m?.label, "1 month ago today")
        let w = Resurfacing.pick(for: day(2026, 5, 1), from: [entry(day(2026, 4, 24), "w")], calendar: cal)
        XCTAssertEqual(w?.label, "1 week ago today")
    }

    func testRandomFallbackIsStableAndPast() {
        let entries = [entry(day(2026, 1, 3)), entry(day(2026, 2, 9)), entry(day(2026, 3, 15))]
        let a = Resurfacing.pick(for: day(2026, 5, 1), from: entries, calendar: cal)
        let b = Resurfacing.pick(for: day(2026, 5, 1), from: entries, calendar: cal)
        XCTAssertNotNil(a)
        XCTAssertEqual(a, b)
    }
}
