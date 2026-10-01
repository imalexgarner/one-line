import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    enum Page: Int { case today, year, timeline, settings }

    @State private var selection: Page = {
        #if DEBUG
        // `-debugTab 1` on launch opens that tab; lets us screenshot each screen from the command line.
        return Page(rawValue: UserDefaults.standard.integer(forKey: "debugTab")) ?? .today
        #else
        return .today
        #endif
    }()

    private var tabs: some View {
        TabView(selection: $selection) {
            Tab("", systemImage: "plus.app", value: Page.today) { TodayView() }
            Tab("", systemImage: "calendar", value: Page.year) { YearView() }
            Tab("", systemImage: "calendar.day.timeline.left", value: Page.timeline) { TimelineView() }
            Tab("", systemImage: "switch.2", value: Page.settings) { SettingsView() }
        }
        .tint(Theme.ink)
    }

    /// The tabs are only mounted after the welcome flow, so Today's autofocused editor
    /// doesn't raise the keyboard behind it.
    var body: some View {
        Group {
            if hasOnboarded {
                tabs.transition(.opacity)
            } else {
                WelcomeView { hasOnboarded = true }.transition(.opacity)
            }
        }
        .animation(.smooth, value: hasOnboarded)
        #if DEBUG
        .task {
            // `-seedDemo 1` on launch fills the journal with sample lines.
            if UserDefaults.standard.bool(forKey: "seedDemo") { SampleData.populate(into: context) }
        }
        #endif
    }
}

#if DEBUG
#Preview {
    RootView().modelContainer(PreviewData.container(.full))
}
#endif
