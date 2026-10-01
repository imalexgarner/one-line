import Foundation

/// What a calendar tile needs to know about a kept day. A plain value, so grid components
/// don't depend on SwiftData.
struct DayMark: Equatable {
    let mood: Mood
    let text: String
}

extension DayMark {
    /// Index entries by day. If a day somehow has two, the first wins.
    static func marks(from entries: [Entry]) -> [Date: DayMark] {
        Dictionary(entries.map { ($0.day, DayMark(mood: $0.mood, text: $0.text)) }, uniquingKeysWith: { first, _ in first })
    }
}
