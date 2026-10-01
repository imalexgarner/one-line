import SwiftUI

/// A quiet centred message for screens with nothing to show yet.
///
///     list.overlay { if items.isEmpty { EmptyState("Nothing kept yet.") } }
struct EmptyState: View {
    let message: String

    init(_ message: String) { self.message = message }

    var body: some View {
        Text(message).font(Theme.caption).foregroundStyle(Theme.quiet)
    }
}

#if DEBUG
#Preview {
    EmptyState("Nothing kept yet.").frame(height: 200).frame(maxWidth: .infinity).background(Theme.paper)
}
#endif
