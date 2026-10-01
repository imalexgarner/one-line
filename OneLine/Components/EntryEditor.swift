import SwiftUI

/// The one-line composer: text, mood colour, save. Autofocuses so the daily loop is open, type, keep.
///
///     EntryEditor { text, mood in save(text, mood) }
///     EntryEditor(text: entry.text, mood: entry.mood, buttonTitle: "Save") { text, mood in … }
struct EntryEditor: View {
    var buttonTitle = "Keep it"
    var onSave: (String, Mood) -> Void

    @State private var draft: String
    @State private var mood: Mood
    @FocusState private var focused: Bool

    init(text: String = "", mood: Mood = .calm, buttonTitle: String = "Keep it",
         onSave: @escaping (String, Mood) -> Void) {
        _draft = State(initialValue: text)
        _mood = State(initialValue: mood)
        self.buttonTitle = buttonTitle
        self.onSave = onSave
    }

    private var canSave: Bool { !EntryText.final(draft).isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField("One line…", text: $draft, axis: .vertical)
                .font(Theme.line()).foregroundStyle(Theme.ink)
                .lineLimit(1...4)
                .focused($focused)
                .submitLabel(.done)
                .onChange(of: draft) { _, new in
                    let limited = EntryText.limit(new)
                    if limited != new { draft = limited }
                }
            MoodPicker(selection: $mood)
            PrimaryButton(buttonTitle) {
                focused = false
                onSave(EntryText.final(draft), mood)
            }
            .disabled(!canSave)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            focused = true
        }
    }
}

#if DEBUG
#Preview("New") {
    EntryEditor { _, _ in }.padding(28).background(Theme.paper)
}

#Preview("Editing") {
    EntryEditor(text: "Rain all day, but the soup was perfect.", mood: .calm, buttonTitle: "Save") { _, _ in }
        .padding(28).background(Theme.paper)
}
#endif
