import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "pencil.line") { TodayView() }
            Tab("Year", systemImage: "square.grid.3x3.fill") { YearView() }
            Tab("Timeline", systemImage: "text.alignleft") { TimelineView() }
            Tab("Settings", systemImage: "gearshape") { SettingsView() }
        }
        .tint(Theme.ink)
    }
}

#if DEBUG
#Preview {
    RootView().modelContainer(PreviewData.container(.full))
}
#endif
