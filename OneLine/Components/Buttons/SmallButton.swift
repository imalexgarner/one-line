import SwiftUI

/// The composer's save button: a solid primary-colour capsule, and when there is nothing to save, a capsule
/// whose surface is the paper colour at 0.2 opacity (the same rule in light and dark). Tapping does nothing
/// while inactive. It deliberately isn't `.disabled`, because
/// the system dims a disabled button's label on its own and that stacks with the surface change.
///
///     SmallButton("Keep it", isActive: canSave) { save() }
struct SmallButton: View {
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
                .foregroundStyle(isActive ? Theme.paper : Theme.quiet)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isActive ? Theme.ink : Theme.ink.opacity(0.05), in: Capsule())
        }
        .buttonStyle(.plain)
        .animation(.smooth, value: isActive)
    }
}

#if DEBUG
#Preview("Active and inactive") {
    HStack(spacing: 16) {
        SmallButton("Keep it", isActive: true) {}
        SmallButton("Keep it", isActive: false) {}
    }
    .padding(40).background(Theme.paper)
}
#endif
