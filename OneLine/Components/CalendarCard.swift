import SwiftUI

/// The calendar half of the combined screen: weeks of day circles, newest week first, scrolled so the
/// week of `focus` leads. Its height is the caller's to set; this fills whatever it is given.
///
///     CalendarCard(weekStarts: weeks, marks: marks, today: today, focus: focus) { select($0) }
struct CalendarCard: View {
    let weekStarts: [Date]
    let marks: [Date: DayMark]
    let today: Date
    var focus: Date?
    /// Extra room above the first row, for a card that extends under the status bar.
    var topInset: CGFloat = 0
    let onSelect: (Date) -> Void

    /// One row: a 34pt circle plus its gap.
    static let rowPitch: CGFloat = 42
    private static let headerTop: CGFloat = 10
    private static let gapBelowHeader: CGFloat = 6
    private static let bottomPadding: CGFloat = 14

    /// The card's height, below any top inset, when it shows `rows` weeks: weekday header, the rows, padding.
    static func height(forRows rows: Int) -> CGFloat {
        headerTop + WeekdayHeader.height + gapBelowHeader + CGFloat(rows) * rowPitch - 8 + bottomPadding
    }

    @State private var topWeek: Date?

    private var focusWeek: Date? { focus.map { WeekLayout.weekStart(of: $0) } }

    var body: some View {
        VStack(spacing: 0) {
            WeekdayHeader().padding(.top, topInset + Self.headerTop)
            weeks
        }
    }

    private var weeks: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(weekStarts, id: \.self) { week in
                    HStack(spacing: 0) {
                        ForEach(WeekLayout.days(inWeekStarting: week), id: \.self) { day in
                            DayCircle(day: day, mark: marks[day], today: today, isFocused: day == focus, onSelect: onSelect)
                        }
                    }
                    .id(week)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, Theme.margin - 6)
        }
        .contentMargins(.top, Self.gapBelowHeader, for: .scrollContent)
        .contentMargins(.bottom, Self.bottomPadding, for: .scrollContent)
        .scrollPosition(id: $topWeek, anchor: .top)
        .scrollIndicators(.hidden)
        .onChange(of: focusWeek) { _, week in
            guard let week, week != topWeek else { return }
            withAnimation(.snappy) { topWeek = week }
        }
        .onAppear { topWeek = focusWeek ?? weekStarts.first }
    }
}

#if DEBUG
#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    let weeks = WeekLayout.weekStarts(from: cal.date(byAdding: .day, value: -40, to: today)!, through: today)
    var marks: [Date: DayMark] = [:]
    for d in 0..<40 where d % 3 != 1 {
        marks[cal.date(byAdding: .day, value: -d, to: today)!] = DayMark(mood: Mood.allCases[d % Mood.allCases.count], text: "x")
    }
    return CalendarCard(weekStarts: weeks, marks: marks, today: today, focus: today) { _ in }
        .frame(height: CalendarCard.height(forRows: 2)).background(Theme.paper)
}
#endif
