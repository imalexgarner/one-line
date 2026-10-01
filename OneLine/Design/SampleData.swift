#if DEBUG
import Foundation
import SwiftData

/// Realistic demo journal for previews and for trying the app by hand (Settings > Developer).
enum SampleData {
    /// Deterministic, so screenshots and previews are stable between runs.
    private struct SplitMix64: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
    }

    static let lines: [String] = [
        "Slow coffee on the balcony. Nowhere to be.", "Finally finished the book I kept putting down.",
        "Long call with Mum. She laughed the whole way through.", "Rain all day, but the soup was perfect.",
        "Tired, but a good tired.", "Nothing special. That's fine.", "A stranger held the door and smiled.",
        "Too much noise today.", "Walked home the long way.", "Cooked for friends.",
        "First proper sunshine in weeks.", "Said no to something and felt lighter.",
        "Missed the train, found a bakery.", "The dog got the zoomies at the park.",
        "Fixed the bug that's haunted me all week.", "Quiet morning, quiet mind.", "Cried at an ad. No regrets.",
        "Got a message from an old friend.", "Cold swim. Felt alive.", "Lost my keys twice. Still smiling.",
        "Dinner at 10pm, worth it.", "Finished the run without stopping.", "A meeting that should've been an email.",
        "Watched the sunset from the roof.", "Tried a new recipe. Mostly worked.",
        "Couldn't focus, went for a walk instead.", "Someone remembered my birthday.", "Early night. Needed it.",
        "Dancing in the kitchen.", "Felt behind on everything today.", "A good conversation on the bus.",
        "Fresh sheets and a long sleep.", "Heard our song in a shop.", "The garden is finally coming up.",
        "Said sorry first.", "Big sky, small worries.", "Bought flowers for no reason.", "Slow Sunday, no plans.",
        "Argued over something silly.", "Proud of how I handled that.", "Made it to the gym, barely.",
        "Lunch in the park. Lovely.", "The light in the flat at 5pm.", "Learned how to fold a fitted sheet.",
        "Coffee with someone who gets me.", "A wave from a neighbour.", "Stayed up too late reading.",
        "Took the stairs. Small win.", "Rain on the window, tea in hand.", "Nervous all day, then it went fine.",
        "Laughed until it hurt.", "Everything felt a bit grey.", "Shipped it.", "Found twenty quid in an old coat.",
        "The first cold morning of autumn.", "Walked past our old street.", "Made someone's day and didn't tell them.",
        "Home, finally.",
    ]

    /// Fills roughly 78% of the days over the last `months` months (skipping today unless asked),
    /// always including the 1-day, 7-day, 30-day and 365-day anchors that resurfacing looks for.
    /// Safe to call repeatedly: days that already have a line are left alone.
    @discardableResult
    static func populate(into context: ModelContext, months: Int = 14, includeToday: Bool = false,
                         now: Date = .now, calendar: Calendar = .current) -> Int {
        let today = calendar.startOfDay(for: now)
        guard let start = calendar.date(byAdding: .month, value: -months, to: today) else { return 0 }
        let span = calendar.dateComponents([.day], from: start, to: today).day ?? 0

        let existing = Set(((try? context.fetch(FetchDescriptor<Entry>())) ?? []).map(\.day))
        let anchors: Set<Int> = [1, 7, 30, 365]
        // Weighted towards pleasant days, like a real journal.
        let moodPool: [Mood] = [.radiant, .radiant, .warm, .warm, .warm, .calm, .calm, .calm, .calm,
                                .flat, .flat, .heavy, .stormy]
        var rng = SplitMix64(state: 42)
        var added = 0

        for daysAgo in (includeToday ? 0 : 1)...max(span, 1) {
            // Always draw, even for days we then skip, so repeated runs make identical choices.
            let roll = Int.random(in: 0..<100, using: &rng)
            let text = lines[Int.random(in: 0..<lines.count, using: &rng)]
            let mood = moodPool[Int.random(in: 0..<moodPool.count, using: &rng)]
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: today),
                  !existing.contains(day),
                  roll < 78 || anchors.contains(daysAgo) else { continue }
            context.insert(Entry(day: day, text: text, mood: mood))
            added += 1
        }
        try? context.save()
        return added
    }

    static func clear(_ context: ModelContext) {
        try? context.delete(model: Entry.self)
        try? context.save()
    }
}
#endif
