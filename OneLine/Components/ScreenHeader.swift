import SwiftUI

/// The serif title shared by every screen, so each one starts in exactly the same place.
struct ScreenHeader: View {
    let title: String

    var body: some View {
        Text(title).font(Theme.title).foregroundStyle(Theme.ink)
            .contentTransition(.numericText())
            .animation(.snappy, value: title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.margin)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview {
    ScreenHeader(title: "What's one thing from today?").background(Theme.paper)
}
#endif
