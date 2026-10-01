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
        /// Today is written too, and the year grid is well filled.
        case full
    }

    static func container(_ scenario: Scenario) -> ModelContainer {
        let container = try! ModelContainer(
            for: Entry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        guard scenario != .empty else { return container }

        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        func add(daysAgo: Int, _ text: String, _ mood: Mood) {
            guard let day = cal.date(byAdding: .day, value: -daysAgo, to: today) else { return }
            container.mainContext.insert(Entry(day: day, text: text, mood: mood))
        }

        // The anchors Resurfacing looks for.
        add(daysAgo: 365, "Slow coffee on the balcony. Nowhere to be.", .warm)
        add(daysAgo: 30, "Finally finished the book I kept putting down.", .calm)
        add(daysAgo: 7, "Long call with Mum. She laughed the whole way through.", .radiant)
        add(daysAgo: 1, "Rain all day, but the soup was perfect.", .calm)

        if scenario == .full {
            add(daysAgo: 0, "Shipped the first screen. It feels like mine.", .radiant)
            let samples: [(String, Mood)] = [
                ("Tired, but a good tired.", .heavy), ("Nothing special. That's fine.", .flat),
                ("A stranger held the door and smiled.", .warm), ("Too much noise today.", .stormy),
                ("Walked home the long way.", .calm), ("Cooked for friends.", .radiant),
            ]
            for offset in stride(from: 2, to: 180, by: 1) where ![7, 30].contains(offset) && offset % 5 != 0 {
                let s = samples[offset % samples.count]
                add(daysAgo: offset, s.0, s.1)
            }
        }
        return container
    }
}
#endif
