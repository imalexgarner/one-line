import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    @State private var isEditing = false

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var todays: Entry? { entries.first { $0.day == today } }
    private var memory: Resurfaced? { Resurfacing.pick(for: today, from: entries) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: today.formatted(.dateTime.weekday(.wide).month(.wide).day()), title: headline)
                VStack(alignment: .leading, spacing: 36) {
                    HeroIllustration("oc-growing")
                    if let todays, !isEditing {
                        Button { withAnimation(.smooth) { isEditing = true } } label: {
                            EntryLine(text: todays.text, mood: todays.mood)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Double tap to edit")
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        EntryEditor(
                            text: todays?.text ?? "",
                            mood: todays?.mood ?? .calm,
                            buttonTitle: todays == nil ? "Keep it" : "Save"
                        ) { text, mood in save(text, mood) }
                    }
                    if let memory, !isEditing {
                        MemoryCard(label: memory.label, text: memory.entry.text, mood: memory.entry.mood)
                    }
                }
                .padding(.horizontal, Theme.margin)
                .padding(.bottom, 24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background { Theme.paper.ignoresSafeArea() }
    }

    private var headline: String {
        if todays == nil { return "What's one thing from today?" }
        return isEditing ? "Change your line." : "Kept."
    }

    private func save(_ text: String, _ mood: Mood) {
        withAnimation(.smooth) {
            try? context.upsertEntry(day: today, text: text, mood: mood)
            isEditing = false
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

#if DEBUG
#Preview("Empty") {
    TodayView().modelContainer(PreviewData.container(.empty))
}

#Preview("Memory + composer") {
    TodayView().modelContainer(PreviewData.container(.needsToday))
}

#Preview("Written today") {
    TodayView().modelContainer(PreviewData.container(.full))
}

#Preview("Dark") {
    TodayView()
        .modelContainer(PreviewData.container(.needsToday))
        .preferredColorScheme(.dark)
}
#endif
