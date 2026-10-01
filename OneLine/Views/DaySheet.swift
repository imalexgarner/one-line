import SwiftUI
import SwiftData

/// A single day from the Year grid: write or edit it if inside the edit window, otherwise just read it.
struct DaySheet: View {
    let day: Date

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var matches: [Entry]
    @State private var mood: Mood = .calm
    @State private var canSave = false
    @State private var saveRequest = 0
    @State private var keyboardUp = false

    init(day: Date) {
        self.day = day
        _matches = Query(filter: #Predicate<Entry> { $0.day == day })
    }

    private var entry: Entry? { matches.first }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(eyebrow: day.formatted(.dateTime.weekday(.wide).month(.wide).day().year()), title: title)
            content
                .padding(.horizontal, Theme.margin)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { Theme.paper.ignoresSafeArea() }
        .presentationDetents([.medium, .large])
        .trackKeyboard($keyboardUp)
        .onPreferenceChange(EntryCanSaveKey.self) { canSave = $0 }
        .onAppear { mood = entry?.mood ?? .calm }
        .safeAreaInset(edge: .bottom) {
            if keyboardUp, EditWindow.isEditable(day) {
                EntryKeyboardBar(mood: $mood, title: entry == nil ? "Keep it" : "Save", canSave: canSave) {
                    saveRequest += 1
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var title: String {
        switch (EditWindow.isEditable(day), entry == nil) {
        case (true, true): "What was one thing?"
        case (true, false): "Change your line"
        case (false, false): "Kept"
        case (false, true): "Not kept."
        }
    }

    @ViewBuilder private var content: some View {
        if EditWindow.isEditable(day) {
            EntryEditor(text: entry?.text ?? "", mood: $mood, saveRequest: saveRequest) { text, mood in
                try? context.upsertEntry(day: day, text: text, mood: mood)
                Haptics.success()
                dismiss()
            }
        } else if let entry {
            EntryLine(text: entry.text, mood: entry.mood)
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
