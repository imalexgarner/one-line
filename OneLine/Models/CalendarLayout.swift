import CoreGraphics
import Foundation

/// The calendar card's rows and where each one sits when scrolled to lead the card, so scrolling can
/// land on a whole row every time. Months run newest first, each with its own heading; rows run oldest
/// first within a month, and a row that is wholly in the future is left out.
struct CalendarLayout {
    struct Month: Identifiable {
        let start: Date
        let rows: [[Date?]]
        var id: Date { start }
    }

    // Metrics shared with the views that draw these rows.
    /// The heading (month name over weekday letters) plus the gap under it is exactly one row slot, so a heading
    /// scrolling through the card is just another slot and no circle is ever cut off.
    static let monthLabelHeight: CGFloat = 17
    static let weekdayRowHeight: CGFloat = 17
    static let rowHeight: CGFloat = 34
    static let gap: CGFloat = 24

    static let headingHeight = monthLabelHeight + weekdayRowHeight
    /// Distance from one row to the next.
    static let rowPitch = rowHeight + gap

    let months: [Month]
    /// Scroll offset that puts a row directly under the pinned heading, by the row's first date in its month.
    let offsets: [Date: CGFloat]
    /// Every such offset, ascending.
    let snapOffsets: [CGFloat]

    init(months starts: [Date], today: Date, calendar: Calendar = .current) {
        var months: [Month] = []
        var offsets: [Date: CGFloat] = [:]
        var y: CGFloat = 0
        for start in starts {
            let rows = MonthLayout.weeks(for: start, calendar: calendar)
                .filter { row in row.contains { $0.map { $0 <= today } ?? false } }
            months.append(Month(start: start, rows: rows))
            for (k, row) in rows.enumerated() {
                if let first = row.compactMap({ $0 }).first { offsets[first] = y + CGFloat(k) * Self.rowPitch }
            }
            // heading, the gap under it, the rows with gaps between, and the gap before the next heading
            y += Self.headingHeight + Self.gap + CGFloat(rows.count) * Self.rowPitch
        }
        self.months = months
        self.offsets = offsets
        self.snapOffsets = offsets.values.sorted()
    }

    /// The offset of the row holding `day`.
    func offset(for day: Date, calendar: Calendar = .current) -> CGFloat? {
        offsets[MonthLayout.rowID(for: day, calendar: calendar)]
    }

    /// The snap offset nearest `y`.
    func nearestOffset(to y: CGFloat) -> CGFloat {
        snapOffsets.min { abs($0 - y) < abs($1 - y) } ?? y
    }
}

extension Array where Element == Date? {
    /// A calendar row's identity: its first date. Unique across months, unlike its position in one.
    var rowID: Date { compactMap { $0 }.first ?? .distantPast }
}
