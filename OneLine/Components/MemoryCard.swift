import SwiftUI

/// A past line resurfaced with its label ("1 year ago today"), tinted by its mood.
///
///     MemoryCard(label: "1 year ago today", text: "…", mood: .warm)
struct MemoryCard: View {
    let label: String
    let text: String
    let mood: Mood

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.system(.caption2, design: .serif).weight(.semibold)).tracking(1.5)
                .foregroundStyle(Theme.quiet)
            Text(text).font(Theme.line(22)).foregroundStyle(Theme.ink)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(mood.color.opacity(0.18), in: RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        MemoryCard(label: "1 year ago today", text: "Slow coffee on the balcony. Nowhere to be.", mood: .warm)
        MemoryCard(label: "3 weeks ago", text: "Everything felt a bit grey.", mood: .heavy)
    }
    .padding(28).background(Theme.paper)
}
#endif
