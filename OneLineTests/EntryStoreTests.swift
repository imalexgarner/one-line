import XCTest
import SwiftData
@testable import OneLine

@MainActor
final class EntryStoreTests: XCTestCase {
    /// Held for the whole test: a context whose container is deallocated traps inside SwiftData.
    private var container: ModelContainer!

    private func makeContext() throws -> ModelContext {
        container = try ModelContainer(for: Entry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        return container.mainContext
    }

    func testUpsertCreatesThenUpdatesSameDay() throws {
        let ctx = try makeContext()
        let day = Date()
        try ctx.upsertEntry(day: day, text: "first", mood: .calm)
        try ctx.upsertEntry(day: day.addingTimeInterval(3600), text: "second", mood: .warm)

        let all = try ctx.fetch(FetchDescriptor<Entry>())
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.text, "second")
        XCTAssertEqual(all.first?.mood, .warm)
    }

    func testEmptyTextIsRejected() throws {
        let ctx = try makeContext()
        XCTAssertNil(try ctx.upsertEntry(day: .now, text: "   \n ", mood: .calm))
        XCTAssertTrue(try ctx.fetch(FetchDescriptor<Entry>()).isEmpty)
    }

    func testTextIsCleanedAndCapped() {
        XCTAssertEqual(EntryText.final("  hello\nworld  "), "hello world")
        XCTAssertEqual(EntryText.limit(String(repeating: "a", count: 300)).count, EntryText.maxLength)
    }
}
