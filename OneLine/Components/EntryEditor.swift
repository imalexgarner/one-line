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

    private func confirm() {
        guard canSave else { return }
        focused = false
        onSave(EntryText.final(draft), mood)
    }

    private var moodMenu: some View {
        Menu {
            Picker("Mood", selection: $mood) {
                ForEach(Mood.allCases) { m in
                    Label(m.name, systemImage: "circle.fill").tint(m.color).tag(m)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Circle().fill(mood.color).frame(width: 20, height: 20)
                Text(mood.name).font(Theme.caption).foregroundStyle(Theme.ink)
                Image(systemName: "chevron.up.chevron.down").font(.caption2).foregroundStyle(Theme.quiet)
            }
            .padding(.vertical, 6)
        }
        .sensoryFeedback(.selection, trigger: mood)
        .accessibilityLabel("Mood, \(mood.name)")
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
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                // Full-width bar: mood pulldown leading, the primary action trailing.
                HStack(spacing: 12) {
                    moodMenu
                    Spacer(minLength: 0)
                    Button(action: confirm) {
                        Text(buttonTitle).font(Theme.button).padding(.horizontal, 8)
                    }
                    .buttonStyle(.borderedProminent).tint(Theme.ink)
                    .foregroundStyle(Theme.paper)
                    .disabled(!canSave)
                }
                .frame(maxWidth: .infinity)
            }
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
