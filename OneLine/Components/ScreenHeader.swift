import SwiftUI

/// The title block shared by all four screens, so each one starts in exactly the same place:
/// a small italic eyebrow over a serif title.
struct ScreenHeader: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow).font(Theme.caption).foregroundStyle(Theme.quiet)
                .contentTransition(.numericText())
            Text(title).font(Theme.title).foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
        }
        .animation(.snappy, value: eyebrow)
        .animation(.snappy, value: title)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.margin)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview {
    ScreenHeader(eyebrow: "Thursday 1 October", title: "What's one thing from today?").background(Theme.paper)
}
#endif
