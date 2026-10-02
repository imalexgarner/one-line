import SwiftUI

/// The calendar half of the combined screen: one month grid after another, newest month first, each under
/// its own heading that stays pinned while the month scrolls. Scrolled so the row of `focus` leads.
/// Its height is the caller's to set; this fills whatever it is given.
///
///     CalendarCard(months: months, marks: marks, today: today, focus: focus) { select($0) }
struct CalendarCard: View {
    let months: [Date]
    let marks: [Date: DayMark]
    let today: Date
    var focus: Date?
    /// Extra room above the weekday header, for a card that extends under the status bar.
    var topInset: CGFloat = 0
    let onSelect: (Date) -> Void

    /// One row: a 34pt circle plus its gap.
    static let rowPitch: CGFloat = 42
    private static let headerTop: CGFloat = 10
    private static let monthHeading: CGFloat = 26
    private static let bottomPadding: CGFloat = 14

    /// The card's height, below any top inset, when it shows `rows` rows: weekday header, the pinned
    /// month heading, the rows, padding.
    static func height(forRows rows: Int) -> CGFloat {
        headerTop + WeekdayHeader.height + monthHeading + CGFloat(rows) * rowPitch - 8 + bottomPadding
    }

    @State private var topRow: Date?

    private var focusRow: Date? { focus.map { MonthLayout.rowID(for: $0) } }

    var body: some View {
        VStack(spacing: 0) {
            WeekdayHeader().padding(.top, topInset + Self.headerTop)
            grid
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVStack(spacing: 8, pinnedViews: .sectionHeaders) {
                ForEach(months, id: \.self) { month in
                    Section {
                        ForEach(rows(in: month), id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                                    if let day {
                                        DayCircle(day: day, mark: marks[day], today: today, isFocused: day == focus, onSelect: onSelect)
                                    } else {
                                        Color.clear.frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.margin - 6)
                            .id(row.compactMap { $0 }.first)
                        }
                    } header: {
                        heading(for: month)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.bottom, Self.bottomPadding, for: .scrollContent)
        .scrollPosition(id: $topRow, anchor: .top)
        .scrollIndicators(.hidden)
        .onChange(of: focusRow) { _, row in
            guard let row, row != topRow else { return }
            withAnimation(.snappy) { topRow = row }
        }
        .onAppear { topRow = focusRow }
    }

    /// A month's rows, leaving out any that are wholly in the future.
    private func rows(in month: Date) -> [[Date?]] {
        MonthLayout.weeks(for: month).filter { row in row.contains { $0.map { $0 <= today } ?? false } }
    }

    private func heading(for month: Date) -> some View {
        let sameYear = Calendar.current.isDate(month, equalTo: today, toGranularity: .year)
        return Text(month.formatted(sameYear ? .dateTime.month(.wide) : .dateTime.month(.wide).year()))
            .font(Theme.label).textCase(.uppercase).tracking(0.6)
            .foregroundStyle(Theme.quiet)
            .frame(maxWidth: .infinity, minHeight: Self.monthHeading, alignment: .leading)
            .padding(.horizontal, Theme.margin)
            .background(Theme.paper)
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    let months = MonthLayout.months(from: cal.date(byAdding: .day, value: -70, to: today)!, through: today)
    var marks: [Date: DayMark] = [:]
    for d in 0..<70 where d % 3 != 1 {
        marks[cal.date(byAdding: .day, value: -d, to: today)!] = DayMark(mood: Mood.allCases[d % Mood.allCases.count], text: "x")
    }
    return CalendarCard(months: months, marks: marks, today: today, focus: today) { _ in }
        .frame(height: CalendarCard.height(forRows: 5)).background(Theme.paper)
}
#endif
