import SwiftUI

/// The full-width call to action. Disable it with `.disabled(_:)`.
///
///     PrimaryButton("Keep it") { save() }.disabled(draft.isEmpty)
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title).font(Theme.button).foregroundStyle(Theme.paper)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent).tint(Theme.ink)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 8) {
        PrimaryButton("Keep it") {}
        PrimaryButton("Keep it") {}.disabled(true)
    }
    .padding(Theme.margin)
}
#endif
