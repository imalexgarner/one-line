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
            Text(title).font(.system(.body, design: .serif).weight(.semibold))
                .frame(maxWidth: .infinity).padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent).tint(Theme.ink)
        .foregroundStyle(Theme.paper)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        PrimaryButton("Keep it") {}
        PrimaryButton("Keep it") {}.disabled(true)
    }
    .padding(28).background(Theme.paper)
}
#endif
