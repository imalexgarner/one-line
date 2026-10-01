import Foundation
import SwiftData

@Model
final class Entry {
    /// Start of the calendar day this line belongs to. One entry per day.
    @Attribute(.unique) var day: Date
    var text: String
    var moodRaw: Int
    var createdAt: Date

    var mood: Mood {
        get { Mood(rawValue: moodRaw) ?? .flat }
        set { moodRaw = newValue.rawValue }
    }

    init(day: Date, text: String, mood: Mood, createdAt: Date = .now) {
        self.day = day
        self.text = text
        self.moodRaw = mood.rawValue
        self.createdAt = createdAt
    }
}
