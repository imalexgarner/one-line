import SwiftUI

/// The calendar half of the combined screen: one month grid after another, newest month first. Each month
/// has a heading, its name over the weekday letters, that stays pinned while the month scrolls. Scrolling
/// always comes to rest on a whole row under the heading, never a half one. Its height is the caller's to
/// set; this fills whatever it is given.
///
///     CalendarCard(layout: layout, marks: marks, today: today, focus: focus) { select($0) }
struct CalendarCard: View {
    let layout: CalendarLayout
    let marks: [Date: DayMark]
    let today: Date
    var focus: Date?
    /// Extra room above the heading, for a card that extends under the status bar.
    var topInset: CGFloat = 0
    /// The tallest the card ever gets, below the inset. Sets the room left under the last month so
    /// its rows can lead the card too; a fixed number, so it can't feed back into the scroll view.
    var maxHeight: CGFloat = 0
    let onSelect: (Date) -> Void

    private static let topPadding: CGFloat = 10
    private static let bottomPadding: CGFloat = 9   // clears the 4.5pt ring of a circle, but stays under gap - 4.5 so no sliver of the next row shows

    /// The card's height, below any top inset, when it shows `rows` whole rows under the heading.
    static func height(forRows rows: Int) -> CGFloat {
        topPadding + CalendarLayout.headingHeight + CGFloat(rows) * CalendarLayout.rowPitch + bottomPadding
    }

    @State private var position = ScrollPosition(edge: .top)

    private var focusOffset: CGFloat? { focus.flatMap { layout.offset(for: $0) } }

    var body: some View {
        // The scroll view is laid out as an overlay on a plain frame, so it hangs from the top of the card at
        // whatever size it wants instead of being centred and pushed up when the card is short.
        Color.clear
            .overlay(alignment: .top) { grid.padding(.top, topInset + Self.topPadding) }
            .clipped()
    }

    private var grid: some View {
        ScrollView {
            LazyVStack(spacing: CalendarLayout.gap, pinnedViews: .sectionHeaders) {
                ForEach(layout.months) { month in
                    Section {
                        ForEach(month.rows, id: \.rowID) { row in
                            HStack(spacing: 0) {
                                ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                                    if let day {
                                        DayCircle(day: day, mark: marks[day], today: today, isFocused: day == focus, onSelect: onSelect)
                                    } else {
                                        Color.clear.frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .frame(height: CalendarLayout.rowHeight)
                            .padding(.horizontal, Theme.margin - 6)
                        }
                    } header: {
                        heading(for: month.start)
                    }
                }
            }
        }
        .scrollPosition($position)
        .scrollTargetBehavior(RowSnap(layout: layout))
        // Room below the last row so the oldest rows can lead the card too.
        .contentMargins(.bottom, max(0, maxHeight - Self.topPadding - CalendarLayout.headingHeight - CalendarLayout.gap - CalendarLayout.rowHeight),
                        for: .scrollContent)
        .scrollIndicators(.hidden)
        .hardTopEdge()
        .onChange(of: focusOffset) { _, y in
            guard let y else { return }
            withAnimation(.snappy) { position.scrollTo(y: y) }
        }
        .onAppear { if let y = focusOffset { position.scrollTo(y: y) } }
    }

    private func heading(for month: Date) -> some View {
        let sameYear = Calendar.current.isDate(month, equalTo: today, toGranularity: .year)
        return VStack(spacing: 0) {
            Text(month.formatted(sameYear ? .dateTime.month(.wide) : .dateTime.month(.wide).year()))
                .font(Theme.label).textCase(.uppercase).tracking(0.6)
                .foregroundStyle(Theme.quiet)
                .dynamicTypeSize(...DynamicTypeSize.large)
                .frame(maxWidth: .infinity, minHeight: CalendarLayout.monthLabelHeight, maxHeight: CalendarLayout.monthLabelHeight, alignment: .leading)
                .padding(.horizontal, Theme.margin)
                .accessibilityAddTraits(.isHeader)
            WeekdayHeader()
        }
        .background { Theme.paper.padding(.bottom, -4) }   // covers the ring of a row sliding under the heading
    }
}

/// Lets a scroll come to rest only where a row sits directly under the pinned heading.
private struct RowSnap: ScrollTargetBehavior {
    let layout: CalendarLayout

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        target.rect.origin.y = layout.nearestOffset(to: target.rect.origin.y)
    }
}

#if DEBUG
#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    let layout = CalendarLayout(months: MonthLayout.months(from: cal.date(byAdding: .day, value: -70, to: today)!, through: today), today: today)
    var marks: [Date: DayMark] = [:]
    for d in 0..<70 where d % 3 != 1 {
        marks[cal.date(byAdding: .day, value: -d, to: today)!] = DayMark(mood: Mood.allCases[d % Mood.allCases.count], text: "x")
    }
    return CalendarCard(layout: layout, marks: marks, today: today, focus: today) { _ in }
        .frame(height: CalendarCard.height(forRows: 3)).background(Theme.paper)
}
#endif
