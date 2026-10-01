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
                    Image("")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Theme.ink.opacity(0.85))
                        .accessibilityHidden(true)
                    if let todays, !isEditing {
                        written(todays)
                    } else {
                        EntryEditor(
                            text: todays?.text ?? "",
                            mood: todays?.mood ?? .calm,
                            buttonTitle: todays == nil ? "Keep it" : "Save"
                        ) { text, mood in save(text, mood) }
                    }
                    if let memory, !isEditing { memoryCard(memory) }
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

    private func written(_ e: Entry) -> some View {
        Button { withAnimation(.smooth) { isEditing = true } } label: {
            HStack(alignment: .top, spacing: 16) {
                RoundedRectangle(cornerRadius: 3).fill(e.mood.color).frame(width: 6)
                Text(e.text).font(Theme.line()).foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Double tap to edit")
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func memoryCard(_ m: Resurfaced) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(m.label.uppercased())
                .font(.system(.caption2, design: .serif).weight(.semibold)).tracking(1.5)
                .foregroundStyle(Theme.quiet)
            Text(m.entry.text).font(Theme.line(22)).foregroundStyle(Theme.ink)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(m.entry.mood.color.opacity(0.18), in: RoundedRectangle(cornerRadius: 20))
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
