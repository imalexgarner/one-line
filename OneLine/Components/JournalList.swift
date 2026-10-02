import SwiftUI

/// The journal half of the combined screen: kept lines, newest first, under month headings.
/// `position` is the day at the top; set it to scroll there.
///
///     JournalList(entries: entries, position: $focus, onDelete: { context.delete($0) })
struct JournalList: View {
    let entries: [Entry]
    @Binding var position: Date?
    /// Room at the foot for a tab bar the list scrolls under.
    var bottomInset: CGFloat = 0
    var onDelete: (Entry) -> Void = { _ in }

    private struct MonthGroup: Identifiable {
        let month: Date
        let entries: [Entry]
        var id: Date { month }
    }

    private var groups: [MonthGroup] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: entries) { cal.dateInterval(of: .month, for: $0.day)?.start ?? $0.day }
        return grouped.keys.sorted(by: >).map { MonthGroup(month: $0, entries: grouped[$0]!.sorted { $0.day > $1.day }) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(groups) { group in
                    Text(group.month.formatted(.dateTime.month(.wide).year()))
                        .font(Theme.caption).foregroundStyle(Theme.quiet)
                        .padding(.top, 20).padding(.bottom, 4)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(group.entries) { e in
                        VStack(alignment: .leading, spacing: 0) {
                            TimelineRow(day: e.day, text: e.text, mood: e.mood)
                            Divider().overlay(Theme.ink.opacity(0.08)).padding(.leading, 24)
                        }
                        .id(e.day)
                        .contextMenu { Button("Delete", systemImage: "trash", role: .destructive) { onDelete(e) } }
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, Theme.margin)
        }
        .contentMargins(.bottom, bottomInset + 24, for: .scrollContent)
        .scrollPosition(id: $position, anchor: .topLeading)
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var position: Date?
    let cal = Calendar.current
    let entries = (0..<10).map {
        Entry(day: cal.date(byAdding: .day, value: -$0 * 2, to: cal.startOfDay(for: .now))!, text: "Line number \($0)",
              mood: Mood.allCases[$0 % Mood.allCases.count])
    }
    return JournalList(entries: entries, position: $position).background(Theme.paper)
}
#endif
