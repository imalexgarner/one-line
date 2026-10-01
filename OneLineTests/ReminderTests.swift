import XCTest
@testable import OneLine

final class ReminderTests: XCTestCase {
    func testMinutesToComponents() {
        let c = Reminder.components(minutes: 21 * 60 + 30)
        XCTAssertEqual(c.hour, 21)
        XCTAssertEqual(c.minute, 30)
    }

    func testDefaultIsNinePM() {
        XCTAssertEqual(Reminder.components(minutes: Reminder.defaultMinutes).hour, 21)
    }
}
