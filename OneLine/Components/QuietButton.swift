import SwiftUI

/// A low-emphasis text button, for the "not now" next to a PrimaryButton.
///
///     QuietButton("Not now") { skip() }
struct QuietButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title).font(Theme.caption).foregroundStyle(Theme.quiet)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    QuietButton("Not now") {}.padding(28).background(Theme.paper)
}
#endif
