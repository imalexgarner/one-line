import SwiftUI

/// One page of the welcome flow: optional illustration, a title, a message, optional extra content, and the
/// page's buttons at the bottom. The buttons are laid out by a GroupButton, so the gap between them is set here
/// with `buttonSpacing` and callers just list their buttons.
///
///     OnboardingPage(illustration: "nc-improve-signup-experience", title: "One line a day.", message: "…") {
///         PrimaryButton("Begin") { next() }
///     }
///
///     OnboardingPage(title: "A gentle nudge?", message: "…") {
///         DatePicker(…)                       // content, above the buttons
///     } actions: {
///         PrimaryButton("Remind me") { remind() }
///         QuietButton("Not now") { skip() }
///     }
struct OnboardingPage<Content: View, Actions: View>: View {
    var illustration: String?
    let title: String
    let message: String
    var buttonSpacing: GroupButtonSpacing
    let content: Content
    let actions: Actions

    init(illustration: String? = nil, title: String, message: String, buttonSpacing: GroupButtonSpacing = .regular,
         @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions) {
        self.illustration = illustration
        self.title = title
        self.message = message
        self.buttonSpacing = buttonSpacing
        self.content = content()
        self.actions = actions()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Spacer(minLength: 0)
            if let illustration { HeroIllustration(illustration, height: 170) }
            VStack(alignment: .leading, spacing: 12) {
                Text(title).font(Theme.title).foregroundStyle(Theme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(message).font(Theme.body).foregroundStyle(Theme.quiet)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            VStack(spacing: 24) {
                content
                GroupButton(buttonSpacing) { actions }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, Theme.margin)
    }
}

extension OnboardingPage where Content == EmptyView {
    /// A page with no content between the message and the buttons.
    init(illustration: String? = nil, title: String, message: String, buttonSpacing: GroupButtonSpacing = .regular,
         @ViewBuilder actions: () -> Actions) {
        self.init(illustration: illustration, title: title, message: message, buttonSpacing: buttonSpacing,
                  content: { EmptyView() }, actions: actions)
    }
}

#if DEBUG
#Preview("One button") {
    OnboardingPage(illustration: "nc-improve-signup-experience", title: "One line a day.",
                   message: "Keep one small thing from every day. Come back tomorrow, and a year from now, to see what you wrote.") {
        PrimaryButton("Begin") {}
    }
    .background(Theme.paper)
}

#Preview("Two buttons") {
    OnboardingPage(title: "A gentle nudge?", message: "Pick a time and we'll remind you once a day.") {
        PrimaryButton("Remind me") {}
        QuietButton("Not now") {}
    }
    .background(Theme.paper)
}
#endif
