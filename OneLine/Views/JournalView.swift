import SwiftUI
import SwiftData

/// The journal in one screen: a calendar card over the list of kept lines, split by a black seam you
/// can drag to show one week, two weeks or the whole month. Tapping a kept day scrolls the list to its
/// line; scrolling the list moves the calendar to match. A blank past day opens its sheet to write.
struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    /// Rows of the calendar the seam snaps to: a week, two weeks, a month.
    private let detentRows = [1, 2, 5]
    private let detentNames = ["1 week", "2 weeks", "Month"]

    @State private var detent: Int = {
        #if DEBUG
        // `-debugRows 5` opens with the calendar expanded.
        let rows = UserDefaults.standard.integer(forKey: "debugRows")
        if let i = [1, 2, 5].firstIndex(of: rows) { return i }
        #endif
        return 1
    }()
    @State private var focus: Date?
    @State private var selected: DayID?

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private var today: Date { Calendar.current.startOfDay(for: .now) }

    var body: some View {
        let marks = DayMark.marks(from: entries)
        let layout = CalendarLayout(months: MonthLayout.months(from: entries.last?.day ?? today, through: today), today: today)
        SplitStack(detents: detentRows.map(CalendarCard.height(forRows:)), index: $detent,
                   label: "Resize calendar", values: detentNames) { inset in
            CalendarCard(layout: layout, marks: marks, today: today, focus: focus, topInset: inset, onSelect: select)
        } bottom: { inset in
            JournalList(entries: entries, position: $focus, bottomInset: inset, onDelete: context.delete)
                .overlay { if entries.isEmpty { EmptyState("Nothing kept yet", message: "Your lines will gather here, week by week.") } }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selected) { DaySheet(day: $0.date) }
        .onAppear {
            guard focus == nil else { return }
            #if DEBUG
            // `-debugFocusDaysAgo 20` opens with the list and calendar on the line from that many days back.
            let ago = UserDefaults.standard.integer(forKey: "debugFocusDaysAgo")
            if ago > 0, let target = Calendar.current.date(byAdding: .day, value: -ago, to: today),
               let entry = entries.first(where: { $0.day <= target }) {
                focus = entry.day
                return
            }
            #endif
            focus = entries.first?.day
        }
    }

    private func select(_ day: Date) {
        Haptics.selection()
        if entries.contains(where: { $0.day == day }) {
            withAnimation(.snappy) { focus = day }
        } else {
            selected = DayID(date: day)
        }
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
