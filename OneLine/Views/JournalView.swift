import SwiftUI
import SwiftData

/// The journal in one screen: a calendar card over the list of kept lines, split by a black seam you
/// can drag to show one week, two weeks or the whole month. Tapping a kept day scrolls the list to its
/// line; scrolling the list moves the calendar to match. A blank past day opens its sheet to write.
struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    @State private var rows: Int = {
        #if DEBUG
        // `-debugRows 5` opens with the calendar expanded.
        let debug = UserDefaults.standard.integer(forKey: "debugRows")
        if debug > 0 { return debug }
        #endif
        return 2
    }()
    @State private var drag: CGFloat = 0
    @State private var focus: Date?
    @State private var selected: DayID?

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private let seam: CGFloat = 12
    private let radius: CGFloat = 24

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var months: [Date] {
        MonthLayout.months(from: entries.last?.day ?? today, through: today)
    }

    /// Row counts the seam snaps to: a week, two weeks, a month.
    private let detents = [1, 2, 5]

    private var minHeight: CGFloat { CalendarCard.height(forRows: detents.first ?? 1) }
    private var maxHeight: CGFloat { CalendarCard.height(forRows: detents.last ?? 1) }

    /// Follows the finger, with resistance past the smallest and largest detents.
    private var calendarHeight: CGFloat {
        let proposed = CalendarCard.height(forRows: rows) + drag
        func resist(_ overshoot: CGFloat) -> CGFloat { min(overshoot * 0.3, 28) }
        if proposed < minHeight { return minHeight - resist(minHeight - proposed) }
        if proposed > maxHeight { return maxHeight + resist(proposed - maxHeight) }
        return proposed
    }

    private func nearestDetent(to height: CGFloat) -> Int {
        detents.min { abs(CalendarCard.height(forRows: $0) - height) < abs(CalendarCard.height(forRows: $1) - height) } ?? rows
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
            CalendarCard(months: months, marks: marks, today: today, focus: focus,
                         topInset: geo.safeAreaInsets.top, onSelect: select)
                .frame(height: calendarHeight + geo.safeAreaInsets.top)
                .background(Theme.paper)
                .clipShape(topShape)
            SeamHandle(label: "Resize calendar", value: "\(rows) \(rows == 1 ? "row" : "rows")", height: seam,
                       onDrag: { drag = $0 }, onEnd: snap, onStep: step)
            JournalList(entries: entries, position: $focus, bottomInset: geo.safeAreaInsets.bottom, onDelete: context.delete)
                .background(Theme.paper)
                .clipShape(bottomShape)
                .overlay { if entries.isEmpty { EmptyState("Nothing kept yet", message: "Your lines will gather here, week by week.") } }
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .sensoryFeedback(.selection, trigger: nearestDetent(to: calendarHeight))
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

    /// Settle on the detent the card was heading for: where it would have coasted to, not just where the finger let go.
    private func snap(_ translation: CGFloat, _ predicted: CGFloat) {
        let target = CalendarCard.height(forRows: rows) + translation + (predicted - translation) * 0.5
        let nearest = nearestDetent(to: min(max(target, minHeight), maxHeight))
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) { rows = nearest; drag = 0 }
    }

    private func step(_ direction: AccessibilityAdjustmentDirection) {
        let i = detents.firstIndex(of: rows) ?? 0
        let next = direction == .increment ? min(i + 1, detents.count - 1) : max(i - 1, 0)
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) { rows = detents[next] }
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
