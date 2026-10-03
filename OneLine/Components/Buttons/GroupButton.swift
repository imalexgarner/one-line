import SwiftUI

/// The stack of actions at the foot of a screen: one PrimaryButton, or a PrimaryButton with a QuietButton under it.
/// The gap is the group's to own, so no button needs to know what sits next to it.
/// How far apart the buttons in a GroupButton sit.
enum GroupButtonSpacing {
    case regular

    var value: CGFloat {
        switch self {
        case .regular: 8
        }
    }
}

struct GroupButton<Content: View>: View {
    let spacing: GroupButtonSpacing
    @ViewBuilder let content: Content

    init(_ spacing: GroupButtonSpacing = .regular, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        VStack(spacing: spacing.value) { content }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 40) {
        GroupButton(.regular) { PrimaryButton("Keep it") {}; QuietButton("Not now") {} }
    }
    .padding(Theme.margin)
}
#endif
