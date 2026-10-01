import SwiftUI
import SwiftData

/// A single day from the Year grid: write or edit it if inside the edit window, otherwise just read it.
struct DaySheet: View {
    let day: Date

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var matches: [Entry]

    init(day: Date) {
        self.day = day
        _matches = Query(filter: #Predicate<Entry> { $0.day == day })
    }

    private var entry: Entry? { matches.first }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(day.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                        .font(Theme.caption).foregroundStyle(Theme.quiet)
                    Text(title).font(Theme.line(26)).foregroundStyle(Theme.ink)
                }
                content
                Spacer(minLength: 0)
            }
            .padding(28)
        }
        .presentationDetents([.medium, .large])
    }

    private var title: String {
        if EditWindow.isEditable(day) { return entry == nil ? "What was one thing?" : "Change your line." }
        return entry == nil ? "Not kept." : ""
    }

    @ViewBuilder private var content: some View {
        if EditWindow.isEditable(day) {
            EntryEditor(text: entry?.text ?? "", mood: entry?.mood ?? .calm,
                        buttonTitle: entry == nil ? "Keep it" : "Save") { text, mood in
                try? context.upsertEntry(day: day, text: text, mood: mood)
                dismiss()
            }
        } else if let entry {
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 3).fill(entry.mood.color).frame(width: 6)
                Text(entry.text).font(Theme.line()).foregroundStyle(Theme.ink)
            }
        } else {
            Text("Days older than a week can't be added.")
                .font(Theme.caption).foregroundStyle(Theme.quiet)
        }
    }
}

#if DEBUG
private let previewCal = Calendar.current
private func previewDay(_ ago: Int) -> Date {
    previewCal.date(byAdding: .day, value: -ago, to: previewCal.startOfDay(for: .now))!
}

#Preview("Blank, editable") {
    DaySheet(day: previewDay(3)).modelContainer(PreviewData.container(.empty))
}

#Preview("Filled, editable") {
    DaySheet(day: previewDay(1)).modelContainer(PreviewData.container(.needsToday))
}

#Preview("Old, read-only") {
    DaySheet(day: previewDay(30)).modelContainer(PreviewData.container(.needsToday))
}

#Preview("Old, blank") {
    DaySheet(day: previewDay(60)).modelContainer(PreviewData.container(.empty))
}
#endif
