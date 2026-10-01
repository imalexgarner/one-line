import SwiftUI

/// A row of mood colours; the selected one grows and gets a ring.
///
///     MoodPicker(selection: $mood)
///     MoodPicker(selection: $mood, compact: true)   // fits the keyboard toolbar
struct MoodPicker: View {
    @Binding var selection: Mood
    var moods: [Mood] = Mood.allCases
    var compact = false

    var body: some View {
        let size: CGFloat = compact ? 22 : 30
        HStack(spacing: compact ? 6 : 14) {
            ForEach(moods) { mood in
                let isSelected = selection == mood
                Circle().fill(mood.color)
                    .frame(width: isSelected ? size + 8 : size, height: isSelected ? size + 8 : size)
                    .overlay(Circle().stroke(Theme.ink, lineWidth: isSelected ? 2 : 0).padding(compact ? -3 : -4))
                    .frame(width: compact ? 36 : 40, height: compact ? 36 : 40)
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.snappy) { selection = mood } }
                    .accessibilityElement()
                    .accessibilityLabel(mood.name)
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var mood: Mood = .calm
    MoodPicker(selection: $mood).padding(28).background(Theme.paper)
}
#endif
