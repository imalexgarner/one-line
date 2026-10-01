import Foundation

/// Which days can still be written or changed. Keeps the journal honest but forgiving.
enum EditWindow {
    /// Today plus the six days before it.
    static let days = 7

    static func isEditable(_ day: Date, now: Date = .now, calendar: Calendar = .current) -> Bool {
        let today = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: day)
        guard target <= today,
              let earliest = calendar.date(byAdding: .day, value: -(days - 1), to: today) else { return false }
        return target >= earliest
    }
}
