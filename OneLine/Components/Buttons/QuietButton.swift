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
            Text(title).font(Theme.button).foregroundStyle(Theme.quiet)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent).tint(Theme.ink .opacity(0.0))
    }
}

#if DEBUG
#Preview {
    QuietButton("Not now") {}.padding(28)
}
#endif
