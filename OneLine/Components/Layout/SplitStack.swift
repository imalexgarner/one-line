import SwiftUI

/// How tall the top card of a `SplitStack` is at one position.
enum SplitDetent: Equatable {
    /// An exact height, below the status bar.
    case height(CGFloat)
    /// Everything except `leaving`: the height of the bottom card plus the seam, which stays peeking out.
    /// With a `step`, rounded down to `base` plus a whole number of steps, so content laid out on that grid
    /// (rows of a calendar) never ends half cut off.
    case remaining(leaving: CGFloat, base: CGFloat = 0, step: CGFloat = 0)
}

/// Two rounded cards one above the other, split by a black seam you drag. The top card extends under
/// the status bar and the bottom card under the home area; each closure is told how much room to leave.
/// The seam follows the finger, pushes back past the ends, ticks at each detent, and on release settles
/// on the detent the flick was heading for. Dragging only re-lays out the cards; it never re-runs the
/// view that owns them.
///
///     SplitStack(detents: [.height(104), .height(272), .remaining(leaving: 200)], index: $detent,
///                label: "Resize calendar", values: ["1 row", "5 rows", "Extended"]) { inset, detent, maxHeight in
///         Calendar(topInset: inset)
///     } bottom: { inset in
///         List(bottomInset: inset)
///     }
struct SplitStack<Top: View, Bottom: View>: View {
    /// The top card's positions, smallest to largest.
    let detents: [SplitDetent]
    @Binding var index: Int
    let label: String
    /// What each detent is called, for VoiceOver.
    let values: [String]
    /// Told the status-bar inset, which detent is current, and the largest height the card reaches.
    @ViewBuilder let top: (_ topInset: CGFloat, _ detent: Int, _ maxHeight: CGFloat) -> Top
    @ViewBuilder let bottom: (_ bottomInset: CGFloat) -> Bottom

    @State private var drag: CGFloat = 0

    private let seam: CGFloat = 12
    private let radius: CGFloat = 24
    private let settle = Animation.snappy(duration: 0.3)

    private var current: Int { min(max(index, 0), detents.count - 1) }

    /// The detents as heights, given the room the whole stack has below the status bar.
    private func heights(room: CGFloat) -> [CGFloat] {
        detents.map {
            switch $0 {
            case .height(let h): return h
            case .remaining(let leaving, let base, let step):
                let available = max(0, room - seam - leaving)
                return step > 0 && available > base ? base + ((available - base) / step).rounded(.down) * step : available
            }
        }
    }

    /// Follows the finger, with resistance past the smallest and largest detents.
    private func height(in heights: [CGFloat]) -> CGFloat {
        let proposed = heights[current] + drag
        let lo = heights.first ?? 0, hi = heights.last ?? 0
        func resist(_ overshoot: CGFloat) -> CGFloat { min(overshoot * 0.3, 28) }
        if proposed < lo { return lo - resist(lo - proposed) }
        if proposed > hi { return hi + resist(proposed - hi) }
        return proposed
    }

    private func nearest(to height: CGFloat, in heights: [CGFloat]) -> Int {
        heights.indices.min { abs(heights[$0] - height) < abs(heights[$1] - height) } ?? 0
    }

    var body: some View {
        GeometryReader { geo in
            let inset = geo.safeAreaInsets
            // The stack's full height, status bar to the foot of the screen, minus the status bar.
            let heights = heights(room: geo.size.height + inset.bottom)
            let height = height(in: heights)
            VStack(spacing: 0) {
                top(inset.top, current, heights.last ?? 0)
                    .frame(height: height + inset.top)
                    .background(Theme.paper)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: radius, bottomTrailing: radius), style: .continuous))
                SeamHandle(label: label, value: values.indices.contains(current) ? values[current] : "", height: seam,
                           onDrag: { drag = $0 },
                           onEnd: { settleDrag($0, $1, heights: heights) },
                           onStep: { step($0) })
                bottom(inset.bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)   // takes whatever the top card leaves
                    .background(Theme.paper)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: radius, topTrailing: radius), style: .continuous))
            }
            .frame(height: geo.size.height + inset.top + inset.bottom, alignment: .top)   // the whole screen
            .ignoresSafeArea(edges: [.top, .bottom])
            .sensoryFeedback(.selection, trigger: nearest(to: height, in: heights))
        }
        .background { Color.black.ignoresSafeArea() }
    }

    /// Settle on the detent the card was heading for: where it would have coasted to, not just where the finger let go.
    private func settleDrag(_ translation: CGFloat, _ predicted: CGFloat, heights: [CGFloat]) {
        let target = heights[current] + translation + (predicted - translation) * 0.5
        let lo = heights.first ?? 0, hi = heights.last ?? 0
        withAnimation(settle) { index = nearest(to: min(max(target, lo), hi), in: heights); drag = 0 }
    }

    private func step(_ direction: AccessibilityAdjustmentDirection) {
        let next = direction == .increment ? min(current + 1, detents.count - 1) : max(current - 1, 0)
        withAnimation(settle) { index = next }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var index = 1
    SplitStack(detents: [.height(100), .height(260), .remaining(leaving: 200)], index: $index,
               label: "Resize", values: ["Small", "Medium", "Extended"]) { _, _, _ in
        Color.orange.opacity(0.4)
    } bottom: { _ in
        Color.blue.opacity(0.2)
    }
}
#endif
