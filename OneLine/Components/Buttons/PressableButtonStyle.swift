import SwiftUI

/// Shrinks its label slightly while pressed, so tiles and tappable lines feel physical.
///
///     Button { … } label: { … }.buttonStyle(PressableButtonStyle(scale: 0.9))
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.94

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}
