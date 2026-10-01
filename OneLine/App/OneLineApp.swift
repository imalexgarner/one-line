import SwiftUI
import SwiftData

@main
struct OneLineApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Entry.self)
    }
}
