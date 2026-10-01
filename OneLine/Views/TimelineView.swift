import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    private struct MonthGroup: Identifiable {
        let month: Date
        let entries: [Entry]
        var id: Date { month }
    }

    private var groups: [MonthGroup] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: entries) { cal.dateInterval(of: .month, for: $0.day)?.start ?? $0.day }
        return grouped.keys.sorted(by: >).map { MonthGroup(month: $0, entries: grouped[$0] ?? []) }
    }

    var body: some View {
        Group {
            List {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.entries) { e in
                            TimelineRow(day: e.day, text: e.text, mood: e.mood)
                                .listRowBackground(Theme.paper)
                                .listRowInsets(EdgeInsets(top: 10, leading: Theme.margin, bottom: 10, trailing: Theme.margin))
                        }
                        .onDelete { offsets in offsets.map { group.entries[$0] }.forEach(context.delete) }
                    } header: {
                        Text(group.month.formatted(.dateTime.month(.wide).year()))
                            .font(Theme.sectionHeader)
                            .foregroundStyle(Theme.ink)
                            .textCase(nil)
                            .padding(.leading, Theme.margin - 16)
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(.compact)
            .environment(\.defaultMinListHeaderHeight, 0)
            .contentMargins(.top, 0, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .softTopEdge()
            .overlay { if entries.isEmpty { EmptyState("Nothing kept yet", message: "Your lines will gather here, month by month.") } }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { Theme.paper.ignoresSafeArea() }
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
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
