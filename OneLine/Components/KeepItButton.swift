import SwiftUI

/// The composer's save button: a solid primary-colour capsule, and when there is nothing to save, the same
/// capsule faded as a whole. Tapping does nothing while faded. It deliberately isn't `.disabled`, because
/// the system dims a disabled button's label on its own and that stacks with the fade.
///
///     KeepItButton("Keep it", isActive: canSave) { save() }
struct KeepItButton: View {
    let title: String
    var isActive = true
    let action: () -> Void

    init(_ title: String = "Keep it", isActive: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button { if isActive { action() } } label: {
            Text(title)
                .font(.system(.body).weight(.semibold))
                .foregroundStyle(Theme.paper)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Theme.ink, in: Capsule())
                .opacity(isActive ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .animation(.smooth, value: isActive)
    }
}

#if DEBUG
#Preview("Active and inactive") {
    HStack(spacing: 16) {
        KeepItButton("Keep it", isActive: true) {}
        KeepItButton("Keep it", isActive: false) {}
    }
    .padding(40).background(Theme.paper)
}

#Preview("Dark") {
    HStack(spacing: 16) {
        KeepItButton("Keep it", isActive: true) {}
        KeepItButton("Keep it", isActive: false) {}
    }
    .padding(40).background(Theme.paper).preferredColorScheme(.dark)
}
#endif
