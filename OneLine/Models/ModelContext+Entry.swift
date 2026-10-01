import Foundation
import SwiftData

extension ModelContext {
    /// Creates the entry for `day`, or updates it if one already exists. Returns nil for empty text.
    @discardableResult
    func upsertEntry(day: Date, text: String, mood: Mood, calendar: Calendar = .current) throws -> Entry? {
        let clean = EntryText.final(text)
        guard !clean.isEmpty else { return nil }
        let key = calendar.startOfDay(for: day)

        var descriptor = FetchDescriptor<Entry>(predicate: #Predicate { $0.day == key })
        descriptor.fetchLimit = 1
        if let existing = try fetch(descriptor).first {
            existing.text = clean
            existing.mood = mood
            try save()
            return existing
        }
        let entry = Entry(day: key, text: clean, mood: mood)
        insert(entry)
        try save()
        return entry
    }
}
