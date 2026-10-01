import SwiftUI
import SwiftData

@main
struct OneLineApp: App {
    init() { Self.styleNavigationBar() }

    /// Native navigation titles, set in serif ink over the paper background.
    private static func styleNavigationBar() {
        func serif(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            return UIFont(descriptor: base.fontDescriptor.withDesign(.serif) ?? base.fontDescriptor, size: size)
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.font: serif(32, .regular), .foregroundColor: Theme.inkUI]
        appearance.titleTextAttributes = [.font: serif(17, .semibold), .foregroundColor: Theme.inkUI]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Entry.self)
    }
}
