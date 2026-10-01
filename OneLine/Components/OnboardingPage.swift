import SwiftUI

/// One page of the welcome flow: optional illustration, a title, a message, and an actions slot at the bottom.
///
///     OnboardingPage(illustration: "nc-improve-signup-experience", title: "One line a day.", message: "…") {
///         PrimaryButton("Begin") { next() }
///     }
struct OnboardingPage<Actions: View>: View {
    var illustration: String?
    let title: String
    let message: String
    @ViewBuilder var actions: Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer(minLength: 0)
            if let illustration { HeroIllustration(illustration, height: 170) }
            VStack(alignment: .leading, spacing: 12) {
                Text(title).font(Theme.title).foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(message).font(Theme.caption).foregroundStyle(Theme.quiet)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            VStack(spacing: 4) { actions }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 32)
    }
}

#if DEBUG
#Preview {
    OnboardingPage(illustration: "nc-improve-signup-experience", title: "One line a day.",
                   message: "Keep one small thing from every day. Come back tomorrow, and a year from now, to see what you wrote.") {
        PrimaryButton("Begin") {}
        QuietButton("Not now") {}
    }
    .background(Theme.paper)
}
#endif
