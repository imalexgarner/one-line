import XCTest
import SwiftData
@testable import OneLine

@MainActor
final class SampleDataTests: XCTestCase {
    private var container: ModelContainer!

    private func makeContext() throws -> ModelContext {
        container = try ModelContainer(for: Entry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return container.mainContext
    }

    func testPopulatesPlentyAndSkipsTodayByDefault() throws {
        let ctx = try makeContext()
        let added = SampleData.populate(into: ctx)
        let all = try ctx.fetch(FetchDescriptor<Entry>())
        XCTAssertEqual(all.count, added)
        XCTAssertGreaterThan(all.count, 250)
        XCTAssertFalse(all.contains { $0.day == Calendar.current.startOfDay(for: .now) })
    }

    func testResurfacingAnchorsAlwaysExist() throws {
        let ctx = try makeContext()
        SampleData.populate(into: ctx)
        let days = Set(try ctx.fetch(FetchDescriptor<Entry>()).map(\.day))
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        for ago in [1, 7, 30, 365] {
            XCTAssertTrue(days.contains(cal.date(byAdding: .day, value: -ago, to: today)!), "missing \(ago) days ago")
        }
    }

    func testRepeatedPopulateIsIdempotentAndClearEmpties() throws {
        let ctx = try makeContext()
        SampleData.populate(into: ctx)
        let first = try ctx.fetchCount(FetchDescriptor<Entry>())
        XCTAssertEqual(SampleData.populate(into: ctx), 0)
        XCTAssertEqual(try ctx.fetchCount(FetchDescriptor<Entry>()), first)
        SampleData.clear(ctx)
        XCTAssertEqual(try ctx.fetchCount(FetchDescriptor<Entry>()), 0)
    }
}
