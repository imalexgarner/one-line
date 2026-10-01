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
        VStack(spacing: 0) {
            ScreenHeader(eyebrow: "\(entries.count) \(entries.count == 1 ? "line" : "lines") kept", title: "Timeline")
            List {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.entries) { e in
                            HStack(alignment: .top, spacing: 14) {
                                Circle().fill(e.mood.color).frame(width: 10, height: 10).padding(.top, 8)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(e.day.formatted(.dateTime.weekday(.abbreviated).day()))
                                        .font(Theme.caption).foregroundStyle(Theme.quiet)
                                    Text(e.text).font(Theme.line(19)).foregroundStyle(Theme.ink)
                                }
                            }
                            .listRowBackground(Theme.paper)
                            .listRowInsets(EdgeInsets(top: 10, leading: Theme.margin, bottom: 10, trailing: Theme.margin))
                        }
                        .onDelete { offsets in offsets.map { group.entries[$0] }.forEach(context.delete) }
                    } header: {
                        Text(group.month.formatted(.dateTime.month(.wide).year()))
                            .font(.system(.subheadline, design: .serif).weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .textCase(nil)
                            .padding(.leading, Theme.margin - 16)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .overlay { if entries.isEmpty { Text("Nothing kept yet.").font(Theme.caption).foregroundStyle(Theme.quiet) } }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { Theme.paper.ignoresSafeArea() }
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
