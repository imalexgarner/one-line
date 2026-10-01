import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    @State private var isEditing = false
    @State private var keyboardUp = false
    @State private var mood: Mood = .calm
    @State private var canSave = false
    @State private var saveRequest = 0
    @Namespace private var barSpace

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var todays: Entry? { entries.first { $0.day == today } }
    private var memory: Resurfaced? { Resurfacing.pick(for: today, from: entries) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(title: headline)
                VStack(alignment: .leading, spacing: 36) {
                    HeroIllustration("nc-improve-signup-experience", height: keyboardUp ? 96 : 200,
                                     alignment: keyboardUp ? .leading : .center)
                    if let todays, !isEditing {
                        Button { mood = todays.mood; withAnimation(.smooth) { isEditing = true } } label: {
                            EntryLine(text: todays.text, mood: todays.mood, barNamespace: barSpace)
                        }
                        .buttonStyle(PressableButtonStyle(scale: 0.98))
                        .accessibilityHint("Double tap to edit")
                        // Instant swap: a cross-fade would overlay the two copies of the text (ghosting).
                        .transition(.identity)
                    } else {
                        EntryEditor(text: todays?.text ?? "", mood: $mood, saveRequest: saveRequest,
                                    barNamespace: barSpace) { text, mood in
                            save(text, mood)
                        }
                        .transition(.identity)
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
        .trackKeyboard($keyboardUp)
        .onPreferenceChange(EntryCanSaveKey.self) { canSave = $0 }
        .onAppear { mood = todays?.mood ?? .calm }
        .onChange(of: isEditing) { _, _ in mood = todays?.mood ?? .calm }
        .safeAreaInset(edge: .bottom) {
            if keyboardUp, todays == nil || isEditing {
                EntryKeyboardBar(mood: $mood, title: todays == nil ? "Keep it" : "Save", canSave: canSave) {
                    saveRequest += 1
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background { Theme.paper.ignoresSafeArea() }
    }

    private var headline: String {
        if todays == nil { return "What's one thing from today?" }
        return isEditing ? "Change your line" : "Kept"
    }

    private func save(_ text: String, _ mood: Mood) {
        withAnimation(.smooth) {
            try? context.upsertEntry(day: today, text: text, mood: mood)
            isEditing = false
        }
        Haptics.success()
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
