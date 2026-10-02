import SwiftUI

/// A past line resurfaced with its label ("1 year ago today"): a quiet keepsake in the mood's colour,
/// with a gradient face, a fine metallic edge, and one slow sweep of light each time it appears.
///
///     MemoryCard(label: "1 year ago today", text: "…", mood: .warm)
struct MemoryCard: View {
    let label: String
    let text: String
    let mood: Mood

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sweep: CGFloat = -0.6

    private let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Rectangle().fill(mood.color).frame(width: 18, height: 1)
                Text(label.uppercased())
                    .font(Theme.label).tracking(2.5)
                    .foregroundStyle(Theme.quiet)
            }
            Text("\u{201C}\(text)\u{201D}")
                .font(.system(.title3, design: .serif).italic())
                .foregroundStyle(Theme.ink)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            shape.fill(LinearGradient(
                colors: [mood.color.opacity(0.34), mood.color.opacity(0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay {
            // A hairline that catches the light on two corners, like a gilded edge.
            shape.strokeBorder(LinearGradient(
                colors: [.white.opacity(0.65), mood.color.opacity(0.25), .white.opacity(0.3), mood.color.opacity(0.55)],
                startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.75)
        }
        .overlay { shimmer }
        .shadow(color: mood.color.opacity(0.28), radius: 22, y: 10)
        .accessibilityElement(children: .combine)
        .onAppear(perform: playShimmer)
    }

    /// A soft diagonal band of light that crosses the card once.
    private var shimmer: some View {
        GeometryReader { geo in
            LinearGradient(colors: [.clear, .white.opacity(0.42), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: geo.size.width * 0.45, height: geo.size.height * 1.8)
                .rotationEffect(.degrees(18))
                .offset(x: geo.size.width * sweep, y: -geo.size.height * 0.4)
                .blendMode(.plusLighter)
        }
        .clipShape(shape)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func playShimmer() {
        guard !reduceMotion else { return }
        sweep = -0.6
        withAnimation(.easeInOut(duration: 1.7).delay(0.4)) { sweep = 1.15 }
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
