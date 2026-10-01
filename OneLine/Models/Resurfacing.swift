import Foundation

/// A past line shown back to the user, with a human label ("1 year ago today").
struct Resurfaced: Equatable {
    let entry: Entry
    let label: String

    static func == (l: Resurfaced, r: Resurfaced) -> Bool { l.entry === r.entry && l.label == r.label }
}

enum Resurfacing {
    /// Picks the most meaningful past entry for `date`:
    /// same day last year(s) > a month ago > a week ago > a stable "random" older line.
    /// Never returns an entry from `date` itself or the future.
    static func pick(for date: Date, from entries: [Entry], calendar: Calendar = .current) -> Resurfaced? {
        let today = calendar.startOfDay(for: date)
        let past = entries.filter { $0.day < today }
        guard !past.isEmpty else { return nil }

        func entry(on day: Date?) -> Entry? {
            guard let day else { return nil }
            let d = calendar.startOfDay(for: day)
            return past.first { $0.day == d }
        }

        for years in 1...10 {
            if let e = entry(on: calendar.date(byAdding: .year, value: -years, to: today)) {
                return Resurfaced(entry: e, label: years == 1 ? "1 year ago today" : "\(years) years ago today")
            }
        }
        if let e = entry(on: calendar.date(byAdding: .month, value: -1, to: today)) {
            return Resurfaced(entry: e, label: "1 month ago today")
        }
        if let e = entry(on: calendar.date(byAdding: .day, value: -7, to: today)) {
            return Resurfaced(entry: e, label: "1 week ago today")
        }

        // Stable per-day pick so the line doesn't change on every launch.
        let sorted = past.sorted { $0.day < $1.day }
        let seed = calendar.ordinality(of: .day, in: .era, for: today) ?? 0
        let e = sorted[seed % sorted.count]
        return Resurfaced(entry: e, label: relativeLabel(from: e.day, to: today, calendar: calendar))
    }

    static func relativeLabel(from day: Date, to today: Date, calendar: Calendar) -> String {
        let days = calendar.dateComponents([.day], from: day, to: today).day ?? 0
        switch days {
        case ..<1: return "Today"
        case 1: return "Yesterday"
        case 2..<14: return "\(days) days ago"
        case 14..<60: return "\(days / 7) weeks ago"
        default: return "\(max(1, days / 30)) months ago"
        }
    }
}
