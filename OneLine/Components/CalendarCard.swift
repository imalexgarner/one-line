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

    /// One row: a 34pt circle plus its gap. The card's detents are multiples of this.
    static let rowPitch: CGFloat = 42
    static let verticalPadding: CGFloat = 14

    @State private var topWeek: Date?

    private var focusWeek: Date? { focus.map { WeekLayout.weekStart(of: $0) } }

    var body: some View {
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
        .contentMargins(.top, topInset + Self.verticalPadding, for: .scrollContent)
        .contentMargins(.bottom, Self.verticalPadding, for: .scrollContent)
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
        .frame(height: 112).background(Theme.paper)
}
#endif
