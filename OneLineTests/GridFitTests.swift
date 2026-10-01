import XCTest
@testable import OneLine

final class GridFitTests: XCTestCase {
    private func assertFits(count: Int, width: CGFloat, height: CGFloat, spacing: CGFloat = 4,
                            file: StaticString = #filePath, line: UInt = #line) {
        let fit = GridFit.best(count: count, width: width, height: height, spacing: spacing)
        let rows = fit.rows(for: count)
        let usedW = CGFloat(fit.columns) * fit.tile + CGFloat(fit.columns - 1) * spacing
        let usedH = CGFloat(rows) * fit.tile + CGFloat(rows - 1) * spacing
        XCTAssertGreaterThan(fit.tile, 0, file: file, line: line)
        XCTAssertLessThanOrEqual(usedW, width, "too wide at \(width)x\(height)", file: file, line: line)
        XCTAssertLessThanOrEqual(usedH, height, "too tall at \(width)x\(height)", file: file, line: line)
    }

    func testYearFitsAcrossPhoneSizes() {
        for (w, h) in [(334, 560), (334, 480), (360, 620), (300, 400), (430, 700)] as [(CGFloat, CGFloat)] {
            assertFits(count: 365, width: w, height: h)
            assertFits(count: 366, width: w, height: h)
        }
    }

    func testTallerSpaceNeverShrinksTiles() {
        let short = GridFit.best(count: 365, width: 334, height: 400, spacing: 4)
        let tall = GridFit.best(count: 365, width: 334, height: 700, spacing: 4)
        XCTAssertGreaterThanOrEqual(tall.tile, short.tile)
    }

    func testDegenerateInputsDoNotCrash() {
        XCTAssertEqual(GridFit.best(count: 0, width: 300, height: 300, spacing: 4).tile, 0)
        XCTAssertEqual(GridFit.best(count: 10, width: 0, height: 300, spacing: 4).tile, 0)
    }
}
