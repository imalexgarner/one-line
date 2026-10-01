import SwiftUI

/// A quiet centred message for places with nothing to show yet.
///
///     EmptyState("Nothing kept yet", message: "Your lines will gather here.")
struct EmptyState: View {
    let title: String
    var message: String?

    init(_ title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(Theme.entrySmall).foregroundStyle(Theme.ink)
            if let message {
                Text(message).font(Theme.caption).foregroundStyle(Theme.quiet)
            }
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    EmptyState("Nothing kept yet", message: "Your lines will gather here, month by month.")
        .padding(28).frame(maxWidth: .infinity, minHeight: 240).background(Theme.paper)
}
#endif
