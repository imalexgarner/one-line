import SwiftUI
import SwiftData

/// The journal in one screen: a calendar card over the list of kept lines, split by a black seam you
/// can drag to show one week, two weeks or the whole month. Tapping a kept day scrolls the list to its
/// line; scrolling the list moves the calendar to match. A blank past day opens its sheet to write.
struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    @State private var rows = 2
    @State private var drag: CGFloat = 0
    @State private var focus: Date?
    @State private var selected: DayID?

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private let seam: CGFloat = 12
    private let radius: CGFloat = 24

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var weekStarts: [Date] {
        WeekLayout.weekStarts(from: entries.last?.day ?? today, through: today)
    }

    /// Row counts the seam snaps to, never more than there are weeks.
    private var detents: [Int] {
        Set([1, 2, 5].map { min($0, max(weekStarts.count, 1)) }).sorted()
    }

    private func height(forRows r: Int) -> CGFloat {
        CGFloat(r) * CalendarCard.rowPitch - 8 + 2 * CalendarCard.verticalPadding
    }

    private var calendarHeight: CGFloat {
        let lo = height(forRows: detents.first ?? 1), hi = height(forRows: detents.last ?? 1)
        return min(max(height(forRows: rows) + drag, lo), hi)
    }

    private var topShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: radius, bottomTrailing: radius), style: .continuous)
    }
    private var bottomShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(cornerRadii: .init(topLeading: radius, topTrailing: radius), style: .continuous)
    }

    var body: some View {
        let marks = DayMark.marks(from: entries)
        GeometryReader { geo in
        VStack(spacing: 0) {
            CalendarCard(weekStarts: weekStarts, marks: marks, today: today, focus: focus,
                         topInset: geo.safeAreaInsets.top, onSelect: select)
                .frame(height: calendarHeight + geo.safeAreaInsets.top)
                .background(Theme.paper)
                .clipShape(topShape)
            SeamHandle(label: "Resize calendar", value: "\(rows) \(rows == 1 ? "row" : "rows")", height: seam,
                       onDrag: { drag = $0 }, onEnd: snap, onStep: step)
            JournalList(entries: entries, position: $focus, onDelete: context.delete)
                .background { bottomShape.fill(Theme.paper).ignoresSafeArea(edges: .bottom) }
                .clipShape(bottomShape)
                .overlay { if entries.isEmpty { EmptyState("Nothing kept yet", message: "Your lines will gather here, week by week.") } }
        }
        .ignoresSafeArea(edges: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.black.ignoresSafeArea() }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selected) { DaySheet(day: $0.date) }
        .onAppear { if focus == nil { focus = entries.first?.day } }
    }

    private func select(_ day: Date) {
        Haptics.selection()
        if entries.contains(where: { $0.day == day }) {
            withAnimation(.snappy) { focus = day }
        } else {
            selected = DayID(date: day)
        }
    }

    private func snap(_ translation: CGFloat) {
        let proposed = calendarHeight
        let nearest = detents.min { abs(height(forRows: $0) - proposed) < abs(height(forRows: $1) - proposed) } ?? rows
        withAnimation(.snappy) { rows = nearest; drag = 0 }
    }

    private func step(_ direction: AccessibilityAdjustmentDirection) {
        let i = detents.firstIndex(of: rows) ?? 0
        let next = direction == .increment ? min(i + 1, detents.count - 1) : max(i - 1, 0)
        withAnimation(.snappy) { rows = detents[next] }
    }
}

#if DEBUG
#Preview("Filled") {
    NavigationStack { JournalView() }.modelContainer(PreviewData.container(.full))
}

#Preview("Empty") {
    NavigationStack { JournalView() }.modelContainer(PreviewData.container(.empty))
}

#Preview("Dark") {
    NavigationStack { JournalView() }
        .modelContainer(PreviewData.container(.full))
        .preferredColorScheme(.dark)
}
#endif
