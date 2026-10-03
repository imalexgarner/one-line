import SwiftUI

/// A written line with its mood colour as a bar on the left.
///
///     EntryLine(text: entry.text, mood: entry.mood)
///     EntryLine(text: entry.text, mood: entry.mood, barNamespace: ns)   // bar morphs into EntryEditor's
struct EntryLine: View {
    let text: String
    let mood: Mood
    var barNamespace: Namespace.ID?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            MoodBar(mood: mood, namespace: barNamespace)
            Text(text).font(Theme.entry).foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
        }
        .fixedSize(horizontal: false, vertical: true)   // the bar matches the text, never the container
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The 6pt mood-coloured bar shared by `EntryLine` and `EntryEditor`. With a namespace, the two
/// copies are matched so the bar stays put while the view swaps between reading and editing.
struct MoodBar: View {
    let mood: Mood
    var namespace: Namespace.ID?

    var body: some View {
        RoundedRectangle(cornerRadius: 3).fill(mood.color).frame(width: 6)
            .animation(.snappy, value: mood)
            .modifier(MatchedBar(namespace: namespace))
    }
}

private struct MatchedBar: ViewModifier {
    let namespace: Namespace.ID?
    func body(content: Content) -> some View {
        if let namespace { content.matchedGeometryEffect(id: "mood-bar", in: namespace) } else { content }
    }
}

#if DEBUG
#Preview {
    EntryLine(text: "Rain all day, but the soup was perfect.", mood: .calm)
        .padding(28).background(Theme.paper)
}
#endif
