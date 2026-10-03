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

extension View {
    /// No fade where scrolling content slides under the top edge (iOS 26+; no-op before).
    @ViewBuilder func hardTopEdge() -> some View {
        if #available(iOS 26, *) {
            self.scrollEdgeEffectHidden(true, for: .top)
        } else {
            self
        }
    }
}

extension View {
    /// Zero top and bottom list-row insets, keeping the system's side insets (iOS 26 overload; earlier
    /// systems get an explicit 20pt, the plain-list default).
    @ViewBuilder func listRowNoVerticalInsets() -> some View {
        if #available(iOS 26, *) {
            self.listRowInsets(.vertical, 0)
        } else {
            self.listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
}
