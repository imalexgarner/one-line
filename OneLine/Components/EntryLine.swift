import SwiftUI

/// A written line with its mood colour as a bar on the left.
///
///     EntryLine(text: entry.text, mood: entry.mood)
struct EntryLine: View {
    let text: String
    let mood: Mood

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 3).fill(mood.color).frame(width: 6)
            Text(text).font(Theme.line()).foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    EntryLine(text: "Rain all day, but the soup was perfect.", mood: .calm)
        .padding(28).background(Theme.paper)
}
#endif
