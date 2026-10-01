import SwiftUI

/// A decorative template-rendered illustration from the asset catalog, tinted to the theme ink
/// so it works in light and dark. Hidden from VoiceOver.
///
///     HeroIllustration("oc-growing")
struct HeroIllustration: View {
    let name: String
    var height: CGFloat = 96

    init(_ name: String, height: CGFloat = 96) {
        self.name = name
        self.height = height
    }

    var body: some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Theme.ink.opacity(0.85))
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HeroIllustration("oc-growing").padding(28).background(Theme.paper)
}
#endif
