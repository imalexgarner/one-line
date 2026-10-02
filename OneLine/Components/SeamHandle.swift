import SwiftUI

/// The black bar between the two cards, with a grabber. Dragging reports a live offset; letting go
/// reports where the drag ended so the caller can snap to a detent. Also adjustable for VoiceOver.
///
///     SeamHandle(label: "Resize calendar", value: "2 rows", onDrag: { drag = $0 },
///                onEnd: { snap(to: $0) }, onStep: { step($0) })
struct SeamHandle: View {
    let label: String
    let value: String
    var height: CGFloat = 12
    let onDrag: (CGFloat) -> Void
    let onEnd: (CGFloat) -> Void
    let onStep: (AccessibilityAdjustmentDirection) -> Void

    var body: some View {
        Color.black
            .frame(height: height)
            .overlay { Capsule().fill(.white.opacity(0.35)).frame(width: 36, height: 4) }
            .overlay {
                Color.clear.frame(height: 44).contentShape(Rectangle())   // generous hit area
                    .gesture(
                        DragGesture()
                            .onChanged { onDrag($0.translation.height) }
                            .onEnded { onEnd($0.translation.height) }
                    )
            }
            .accessibilityElement()
            .accessibilityLabel(label)
            .accessibilityValue(value)
            .accessibilityAdjustableAction(onStep)
    }
}

#if DEBUG
#Preview {
    SeamHandle(label: "Resize", value: "2 rows", onDrag: { _ in }, onEnd: { _ in }, onStep: { _ in })
}
#endif
