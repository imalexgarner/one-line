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
}
