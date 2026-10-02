import Foundation

enum WeekLayout {
    /// Start-of-week dates from the week containing `today` back to the week containing `earliest`,
    /// newest first. Always includes the current week.
    static func weekStarts(from earliest: Date, through today: Date, calendar: Calendar = .current) -> [Date] {
        guard let current = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        let first = calendar.dateInterval(of: .weekOfYear, for: min(earliest, today))?.start ?? current
        var result: [Date] = []
        var cursor = current
        while cursor >= first {
            result.append(cursor)
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return result
    }

    /// The seven days of the week starting at `weekStart`.
    static func days(inWeekStarting weekStart: Date, calendar: Calendar = .current) -> [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    /// The start of the week containing `day`.
    static func weekStart(of day: Date, calendar: Calendar = .current) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: day)?.start ?? day
    }
}
