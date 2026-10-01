#if DEBUG
import Foundation
import SwiftData

/// In-memory stores with sample lines, for SwiftUI previews only.
@MainActor
enum PreviewData {
    enum Scenario {
        /// Nothing written yet: first launch.
        case empty
        /// Past lines exist, today is still blank: composer plus a memory card.
        case needsToday
        /// Today is written too.
        case full
    }

    static func container(_ scenario: Scenario) -> ModelContainer {
        let container = try! ModelContainer(
            for: Entry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        guard scenario != .empty else { return container }
        SampleData.populate(into: container.mainContext, includeToday: scenario == .full)
        return container
    }
}
#endif
