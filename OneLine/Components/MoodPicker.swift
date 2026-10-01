import SwiftUI

/// A row of mood colours; the selected one grows and gets a ring.
///
///     MoodPicker(selection: $mood)
struct MoodPicker: View {
    @Binding var selection: Mood
    var moods: [Mood] = Mood.allCases

    var body: some View {
        HStack(spacing: 14) {
            ForEach(moods) { mood in
                let isSelected = selection == mood
                Circle().fill(mood.color)
                    .frame(width: isSelected ? 38 : 30, height: isSelected ? 38 : 30)
                    .overlay(Circle().stroke(Theme.ink, lineWidth: isSelected ? 2 : 0).padding(-4))
                    .frame(width: 40, height: 40)
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
