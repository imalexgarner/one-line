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
        HStack(spacing: compact ? 0 : 14) {
            ForEach(moods) { mood in
                // Compact: spread the circles evenly across the full toolbar width.
                if compact && mood != moods.first { Spacer(minLength: 0) }
                let isSelected = selection == mood
                Circle().fill(mood.color)
                    .frame(width: isSelected ? size + 8 : size, height: isSelected ? size + 8 : size)
                    .overlay(Circle().stroke(Theme.ink, lineWidth: isSelected ? 2 : 0).padding(compact ? -3 : -4))
                    .frame(width: compact ? 36 : 40, height: compact ? 34 : 40)
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.snappy) { selection = mood } }
                    .accessibilityElement()
                    .accessibilityLabel(mood.name)
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .frame(maxWidth: compact ? .infinity : nil)
        // Lifts the circles off the keyboard edge; the system toolbar itself can't be inset.
        .padding(.bottom, compact ? 6 : 0)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var mood: Mood = .calm
    MoodPicker(selection: $mood).padding(28).background(Theme.paper)
}
#endif
