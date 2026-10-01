import SwiftUI

/// A decorative template-rendered illustration from the asset catalog, tinted to the theme ink
/// so it works in light and dark. Hidden from VoiceOver.
///
///     HeroIllustration("oc-growing")
///     HeroIllustration("oc-growing", height: 200, alignment: .center)
struct HeroIllustration: View {
    let name: String
    var height: CGFloat = 96
    var alignment: Alignment = .leading

    init(_ name: String, height: CGFloat = 96, alignment: Alignment = .leading) {
        self.name = name
        self.height = height
        self.alignment = alignment
    }

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .frame(maxWidth: .infinity, alignment: alignment)
            .foregroundStyle(Theme.ink.opacity(0.85))
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HeroIllustration("oc-growing").padding(28).background(Theme.paper)
}
#endif
