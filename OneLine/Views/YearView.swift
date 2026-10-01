import SwiftUI
import SwiftData

struct YearView: View {
    @Query private var entries: [Entry]
    @State private var year = Calendar.current.component(.year, from: .now)
    @State private var selected: DayID?

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private var cal: Calendar { .current }
    private var today: Date { cal.startOfDay(for: .now) }
    private var byDay: [Date: Entry] { Dictionary(uniqueKeysWithValues: entries.map { ($0.day, $0) }) }

    private var days: [Date] {
        guard let start = cal.date(from: DateComponents(year: year, month: 1, day: 1)),
              let range = cal.range(of: .day, in: .year, for: start) else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(String(year)).font(Theme.line(34)).foregroundStyle(Theme.ink)
                    Spacer()
                    Button { year -= 1 } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Previous year")
                    Button { year += 1 } label: { Image(systemName: "chevron.right") }
                        .disabled(year >= cal.component(.year, from: .now))
                        .accessibilityLabel("Next year")
                }
                .foregroundStyle(Theme.ink)

                let byDay = byDay
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 14), spacing: 5) {
                    ForEach(days, id: \.self) { d in
                        tile(d, entry: byDay[d])
                    }
                }
                Text("\(entries.filter { cal.component(.year, from: $0.day) == year }.count) days kept")
                    .font(Theme.caption).foregroundStyle(Theme.quiet)
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background { Theme.paper.ignoresSafeArea() }
        .sheet(item: $selected) { DaySheet(day: $0.date) }
    }

    private func tile(_ d: Date, entry: Entry?) -> some View {
        Button { selected = DayID(date: d) } label: {
            RoundedRectangle(cornerRadius: 3)
                .fill(entry?.mood.color ?? Theme.ink.opacity(0.08))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    if d == today { RoundedRectangle(cornerRadius: 3).stroke(Theme.ink, lineWidth: 1.5) }
                }
        }
        .buttonStyle(.plain)
        .disabled(d > today)
        .accessibilityLabel(d.formatted(.dateTime.month(.wide).day()))
        .accessibilityValue(entry.map { "\($0.mood.name): \($0.text)" } ?? "No entry")
    }
}

#if DEBUG
#Preview("Filled") {
    YearView().modelContainer(PreviewData.container(.full))
}

#Preview("Empty") {
    YearView().modelContainer(PreviewData.container(.empty))
}

#Preview("Dark") {
    YearView()
        .modelContainer(PreviewData.container(.full))
        .preferredColorScheme(.dark)
}
#endif
