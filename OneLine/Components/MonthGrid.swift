import SwiftUI

/// One month as a calendar with day numbers, sized to the space it is given.
///
///     MonthGrid(month: monthStart, marks: marks, today: today) { day in open(day) }
struct MonthGrid: View {
    let month: Date
    let marks: [Date: DayMark]
    let today: Date
    var spacing: CGFloat = 6
    let onSelect: (Date) -> Void

    private let headerHeight: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let cells = MonthLayout.cells(for: month)
            let rows = max(1, cells.count / 7)
            let colWidth = (geo.size.width - 6 * spacing) / 7
            let availableHeight = geo.size.height - headerHeight - spacing
            let cellHeight = min(colWidth * 1.35, (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows))

            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    ForEach(Array(MonthLayout.weekdaySymbols().enumerated()), id: \.offset) { _, symbol in
                        Text(symbol).font(Theme.caption).foregroundStyle(Theme.quiet)
                            .frame(width: colWidth, height: headerHeight)
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(colWidth), spacing: spacing), count: 7), spacing: spacing) {
                    ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                        if let day {
                            DayTile(day: day, mark: marks[day], today: today, cornerRadius: 10,
                                    showsNumber: true, onSelect: onSelect)
                                .frame(width: colWidth, height: cellHeight)
                        } else {
                            Color.clear.frame(width: colWidth, height: cellHeight)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 16)
    }
}

#if DEBUG
#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    let month = cal.dateInterval(of: .month, for: today)!.start
    var marks: [Date: DayMark] = [:]
    for d in 0..<28 {
        if let day = cal.date(byAdding: .day, value: d, to: month), day < today, d % 3 != 0 {
            marks[day] = DayMark(mood: Mood.allCases[d % Mood.allCases.count], text: "Sample")
        }
    }
    return MonthGrid(month: month, marks: marks, today: today) { _ in }
        .frame(height: 560).background(Theme.paper)
}
#endif
