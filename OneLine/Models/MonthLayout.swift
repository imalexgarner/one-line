import Foundation

enum MonthLayout {
    /// The cells of a month grid: leading blanks so day 1 lands on its weekday, the days, then trailing
    /// blanks to complete the last week. Always a multiple of 7.
    static func cells(for month: Date, calendar: Calendar = .current) -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let days = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let first = interval.start
        let weekday = calendar.component(.weekday, from: first)
        let lead = (weekday - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: lead)
        for d in days { cells.append(calendar.date(byAdding: .day, value: d - 1, to: first)) }
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }

    /// Single-letter weekday headings in the calendar's own week order.
    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        return (0..<7).map { symbols[(calendar.firstWeekday - 1 + $0) % 7] }
    }

    /// A month's `cells`, split into rows of seven.
    static func weeks(for month: Date, calendar: Calendar = .current) -> [[Date?]] {
        let cells = cells(for: month, calendar: calendar)
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }

    /// Month starts from the month of `today` back to the month of `earliest`, newest first.
    static func months(from earliest: Date, through today: Date, calendar: Calendar = .current) -> [Date] {
        guard let current = calendar.dateInterval(of: .month, for: today)?.start else { return [] }
        let first = calendar.dateInterval(of: .month, for: min(earliest, today))?.start ?? current
        var result: [Date] = []
        var cursor = current
        while cursor >= first {
            result.append(cursor)
            guard let previous = calendar.date(byAdding: .month, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return result
    }

    /// Identifies the calendar row holding `day` within its own month: the first date of that row
    /// that belongs to the month. A week that straddles two months is two rows, one in each.
    static func rowID(for day: Date, calendar: Calendar = .current) -> Date {
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: day)?.start ?? day
        let monthStart = calendar.dateInterval(of: .month, for: day)?.start ?? day
        return max(weekStart, monthStart)
    }
}
