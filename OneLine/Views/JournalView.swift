import SwiftUI
import SwiftData

/// The journal in one screen: a calendar card over the list of kept lines, split by a black seam you
/// can drag to show one row of the calendar, five, or all of it. Tapping a kept day scrolls the list to its
/// line; scrolling the list moves the calendar to match. A blank past day opens its sheet to write.
struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    /// One row, five rows, then the calendar fills the screen and the list peeks out below.
    private let detents: [SplitDetent] = [
        .height(CalendarCard.height(forRows: 1)),
        .height(CalendarCard.height(forRows: 5)),
        .remaining(leaving: 200, base: CalendarCard.height(forRows: 0), step: CalendarLayout.rowPitch),
    ]
    private let detentNames = ["1 row", "5 rows", "Extended"]

    @State private var detent: Int = {
        #if DEBUG
        let rows = UserDefaults.standard.integer(forKey: "debugRows")   // 1, 5, or 99 for extended
        if let i = [1, 5, 99].firstIndex(of: rows) { return i }
        #endif
        return 0
    }()
    @State private var focus: Date?
    @State private var selected: DayID?

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private var today: Date { Calendar.current.startOfDay(for: .now) }

    var body: some View {
        let marks = DayMark.marks(from: entries)
        let layout = CalendarLayout(months: MonthLayout.months(from: entries.last?.day ?? today, through: today), today: today)
        SplitStack(detents: detents, index: $detent, label: "Resize calendar", values: detentNames) { inset, _, maxHeight in
            CalendarCard(layout: layout, marks: marks, today: today, focus: focus, topInset: inset,
                         maxHeight: maxHeight, onSelect: select)
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
#endif
