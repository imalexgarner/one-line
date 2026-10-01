import SwiftUI

extension View {
    /// A soft fade where scrolling content slides under the navigation title (iOS 26+; no-op before).
    @ViewBuilder func softTopEdge() -> some View {
        if #available(iOS 26, *) {
            self.scrollEdgeEffectStyle(.soft, for: .top)
        } else {
            self
        }
    }
}
