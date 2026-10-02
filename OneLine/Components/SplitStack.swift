import SwiftUI

/// Two rounded cards one above the other, split by a black seam you drag. The top card extends under
/// the status bar and the bottom card under the home area; each closure is told how much room to leave.
/// The seam follows the finger, pushes back past the ends, ticks at each detent, and on release settles
/// on the detent the flick was heading for. Dragging only re-lays out the cards; it never re-runs the
/// view that owns them.
///
///     SplitStack(detents: [104, 146, 272], index: $detent, label: "Resize calendar",
///                values: ["1 week", "2 weeks", "Month"]) { inset in
///         Calendar(topInset: inset)
///     } bottom: { inset in
///         List(bottomInset: inset)
///     }
struct SplitStack<Top: View, Bottom: View>: View {
    /// Heights of the top card, below the status bar, ascending.
    let detents: [CGFloat]
    @Binding var index: Int
    let label: String
    /// What each detent is called, for VoiceOver.
    let values: [String]
    @ViewBuilder let top: (_ topInset: CGFloat) -> Top
    @ViewBuilder let bottom: (_ bottomInset: CGFloat) -> Bottom

    @State private var drag: CGFloat = 0

    private let seam: CGFloat = 12
    private let radius: CGFloat = 24
    private let settle = Animation.snappy(duration: 0.3)

    private var current: Int { min(max(index, 0), detents.count - 1) }

    /// Follows the finger, with resistance past the smallest and largest detents.
    private var height: CGFloat {
        let proposed = detents[current] + drag
        let lo = detents.first ?? 0, hi = detents.last ?? 0
        func resist(_ overshoot: CGFloat) -> CGFloat { min(overshoot * 0.3, 28) }
        if proposed < lo { return lo - resist(lo - proposed) }
        if proposed > hi { return hi + resist(proposed - hi) }
        return proposed
    }

    private func nearest(to height: CGFloat) -> Int {
        detents.indices.min { abs(detents[$0] - height) < abs(detents[$1] - height) } ?? 0
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                top(geo.safeAreaInsets.top)
                    .frame(height: height + geo.safeAreaInsets.top)
                    .background(Theme.paper)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: radius, bottomTrailing: radius), style: .continuous))
                SeamHandle(label: label, value: values.indices.contains(current) ? values[current] : "", height: seam,
                           onDrag: { drag = $0 }, onEnd: settleDrag, onStep: step)
                bottom(geo.safeAreaInsets.bottom)
                    .background(Theme.paper)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: radius, topTrailing: radius), style: .continuous))
            }
            .ignoresSafeArea(edges: [.top, .bottom])
            .sensoryFeedback(.selection, trigger: nearest(to: height))
        }
        .background { Color.black.ignoresSafeArea() }
    }

    /// Settle on the detent the card was heading for: where it would have coasted to, not just where the finger let go.
    private func settleDrag(_ translation: CGFloat, _ predicted: CGFloat) {
        let target = detents[current] + translation + (predicted - translation) * 0.5
        let lo = detents.first ?? 0, hi = detents.last ?? 0
        withAnimation(settle) { index = nearest(to: min(max(target, lo), hi)); drag = 0 }
    }

    private func step(_ direction: AccessibilityAdjustmentDirection) {
        let next = direction == .increment ? min(current + 1, detents.count - 1) : max(current - 1, 0)
        withAnimation(settle) { index = next }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var index = 1
    SplitStack(detents: [100, 160, 300], index: $index, label: "Resize", values: ["Small", "Medium", "Large"]) { _ in
        Color.orange.opacity(0.4)
    } bottom: { _ in
        Color.blue.opacity(0.2)
    }
}
#endif
