import SwiftUI

/// The one-line composer: text, mood colour, save. Shared by Today and the day sheet.
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
            HStack(spacing: 14) {
                ForEach(Mood.allCases) { m in
                    Circle().fill(m.color)
                        .frame(width: mood == m ? 38 : 30, height: mood == m ? 38 : 30)
                        .overlay(Circle().stroke(Theme.ink, lineWidth: mood == m ? 2 : 0).padding(-4))
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                        .onTapGesture { withAnimation(.snappy) { mood = m } }
                        .accessibilityElement()
                        .accessibilityLabel(m.name)
                        .accessibilityAddTraits(mood == m ? [.isButton, .isSelected] : .isButton)
                }
            }
            Button {
                focused = false
                onSave(EntryText.final(draft), mood)
            } label: {
                Text(buttonTitle).font(.system(.body, design: .serif).weight(.semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent).tint(Theme.ink)
            .foregroundStyle(Theme.paper)
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
