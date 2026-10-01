import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { e in
                    HStack(alignment: .top, spacing: 14) {
                        Circle().fill(e.mood.color).frame(width: 10, height: 10).padding(.top, 8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(e.day.formatted(.dateTime.month().day().year()))
                                .font(Theme.caption).foregroundStyle(Theme.quiet)
                            Text(e.text).font(Theme.line(19)).foregroundStyle(Theme.ink)
                        }
                    }
                    .listRowBackground(Theme.paper)
                }
                .onDelete { idx in idx.map { entries[$0] }.forEach(context.delete) }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("Timeline")
            .overlay { if entries.isEmpty { Text("Nothing kept yet.").font(Theme.caption).foregroundStyle(Theme.quiet) } }
        }
    }
}

#if DEBUG
#Preview("Filled") {
    TimelineView().modelContainer(PreviewData.container(.full))
}

#Preview("Empty") {
    TimelineView().modelContainer(PreviewData.container(.empty))
}

#Preview("Dark") {
    TimelineView()
        .modelContainer(PreviewData.container(.full))
        .preferredColorScheme(.dark)
}
#endif
