import SwiftUI

/// Reports whether the editor has something to save, so the host's bar can enable its button.
struct EntryCanSaveKey: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = nextValue() }
}

/// The floating bar that rides above the keyboard: mood menu leading, save trailing.
/// Hosts place it with `.safeAreaInset(edge: .bottom)`; the 8pt below it is the gap to the keyboard.
///
///     EntryKeyboardBar(mood: $mood, title: "Keep it", canSave: canSave) { saveRequest += 1 }
struct EntryKeyboardBar: View {
    @Binding var mood: Mood
    var title = "Keep it"
    var canSave: Bool
    var onSave: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Menu {
                Picker("Mood", selection: $mood) {
                    ForEach(Mood.allCases) { m in
                        Label(m.name, systemImage: "circle.fill").tint(m.color).tag(m)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Circle().fill(mood.color).frame(width: 16, height: 16)
                    Text(mood.name).font(Theme.body).foregroundStyle(Theme.ink)
                    Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundStyle(Theme.quiet)
                }
                .padding(.leading, 8)
            }
            .sensoryFeedback(.selection, trigger: mood)
            .accessibilityLabel("Mood, \(mood.name)")
            Spacer(minLength: 0)
            SmallButton(title, isActive: canSave, action: onSave)
        }
        .padding(8)
        .glassBackground()
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

private extension View {
    /// Liquid Glass on iOS 26+, a plain material on earlier systems (deployment target is 18).
    @ViewBuilder func glassBackground() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: Capsule())
        } else {
            self.background(.regularMaterial, in: Capsule())
        }
    }
}

extension View {
    /// Mirrors keyboard visibility into `isUp`, animated.
    func trackKeyboard(_ isUp: Binding<Bool>) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation(.smooth) { isUp.wrappedValue = true }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.smooth) { isUp.wrappedValue = false }
            }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var mood: Mood = .calm
    EntryKeyboardBar(mood: $mood, canSave: true) {}
}
#endif
