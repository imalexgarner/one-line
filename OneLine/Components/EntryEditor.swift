import SwiftUI

/// The one-line composer: the text field. Autofocuses so the daily loop is open, type, keep.
/// The mood menu and save button live in `EntryKeyboardBar`, placed by the host above the keyboard.
/// The host requests a save by bumping `saveRequest`; the editor reports `canSave` via `EntryCanSaveKey`.
///
///     EntryEditor(mood: $mood, saveRequest: saveRequest) { text, mood in save(text, mood) }
///     EntryEditor(text: entry.text, mood: $mood, saveRequest: saveRequest) { text, mood in … }
struct EntryEditor: View {
    @Binding var mood: Mood
    var saveRequest = 0
    var onSave: (String, Mood) -> Void

    @State private var draft: String
    @FocusState private var focused: Bool

    init(text: String = "", mood: Binding<Mood>, saveRequest: Int = 0,
         onSave: @escaping (String, Mood) -> Void) {
        _draft = State(initialValue: text)
        _mood = mood
        self.saveRequest = saveRequest
        self.onSave = onSave
    }

    private var canSave: Bool { !EntryText.final(draft).isEmpty }

    private func confirm() {
        guard canSave else { return }
        focused = false
        onSave(EntryText.final(draft), mood)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField("One line…", text: $draft, axis: .vertical)
                .font(Theme.entry).foregroundStyle(Theme.ink)
                .lineLimit(1...4)
                .focused($focused)
                .submitLabel(.done)
                .onChange(of: draft) { old, new in
                    // The keyboard's blue Done key arrives as a typed newline in a vertical field.
                    // A single typed "\n" confirms; pasted multi-line text just gets flattened.
                    if new.count == old.count + 1, new.contains("\n") {
                        draft = EntryText.limit(new)
                        confirm()
                        return
                    }
                    let limited = EntryText.limit(new)
                    if limited != new { draft = limited }
                }
        }
        .onChange(of: saveRequest) { _, _ in confirm() }
        .preference(key: EntryCanSaveKey.self, value: canSave)
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            focused = true
        }
    }
}

#if DEBUG
#Preview("New") {
    @Previewable @State var mood: Mood = .calm
    EntryEditor(mood: $mood) { _, _ in }.padding(28).background(Theme.paper)
}

#Preview("Editing") {
    @Previewable @State var mood: Mood = .calm
    EntryEditor(text: "Rain all day, but the soup was perfect.", mood: $mood) { _, _ in }
        .padding(28).background(Theme.paper)
}
#endif
