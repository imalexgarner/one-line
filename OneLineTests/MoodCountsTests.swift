import XCTest
@testable import OneLine

final class MoodCountsTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)
    private func day(_ m: Int, _ d: Int) -> Date { cal.date(from: DateComponents(year: 2026, month: m, day: d))! }

    func testCountsOnlyTheRequestedMonth() {
        let marks: [Date: DayMark] = [
            day(5, 1): DayMark(mood: .calm, text: "a"), day(5, 2): DayMark(mood: .calm, text: "b"),
            day(5, 3): DayMark(mood: .warm, text: "c"), day(6, 1): DayMark(mood: .stormy, text: "d"),
        ]
        let counts = MoodCounts.counts(in: marks, month: day(5, 15), calendar: cal)
        XCTAssertEqual(counts, [.calm: 2, .warm: 1])
    }

    func testDominantPicksHighestAndBreaksTiesStably() {
        XCTAssertEqual(MoodCounts.dominant([.calm: 3, .warm: 5]), .warm)
        XCTAssertEqual(MoodCounts.dominant([.warm: 2, .calm: 2]), .warm)   // earlier case wins a tie
        XCTAssertNil(MoodCounts.dominant([:]))
    }
}
