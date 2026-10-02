import XCTest

final class SeamDragTests: XCTestCase {
    func testDraggingTheSeamResizesTheCalendar() {
        let app = XCUIApplication()
        app.launchArguments = ["-hasOnboarded", "1", "-seedDemo", "1", "-debugTab", "1"]
        app.launch()
        let seam = app.descendants(matching: .any)["Resize calendar"].firstMatch
        XCTAssertTrue(seam.waitForExistence(timeout: 10))
        let before = seam.frame.midY
        let valueBefore = seam.value as? String

        let start = seam.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: 160)))
        sleep(1)
        let after = seam.frame.midY
        print("SEAM before \(before) after \(after) value \(valueBefore ?? "-") -> \(seam.value as? String ?? "-")")
        XCTAssertGreaterThan(after, before + 20, "the seam should have moved down")
        XCTAssertEqual(seam.value as? String, "5 rows")

        let mid = seam.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        mid.press(forDuration: 0.1, thenDragTo: mid.withOffset(CGVector(dx: 0, dy: -400)))
        sleep(1)
        let collapsed = seam.frame.midY
        print("SEAM collapsed \(collapsed) value \(seam.value as? String ?? "-")")
        XCTAssertLessThan(collapsed, after - 20, "the seam should have moved back up")
        XCTAssertEqual(seam.value as? String, "1 row")

        let low = seam.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        low.press(forDuration: 0.1, thenDragTo: low.withOffset(CGVector(dx: 0, dy: 900)))
        sleep(1)
        print("SEAM extended \(seam.frame.midY) value \(seam.value as? String ?? "-")")
        XCTAssertEqual(seam.value as? String, "Extended")
    }
}
