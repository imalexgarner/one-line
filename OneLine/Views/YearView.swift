import SwiftUI
import SwiftData

struct YearView: View {
    @Query private var entries: [Entry]
    @State private var year = Calendar.current.component(.year, from: .now)

    private var cal: Calendar { .current }
    private var byDay: [Date: Entry] { Dictionary(uniqueKeysWithValues: entries.map { ($0.day, $0) }) }

    private var days: [Date] {
        guard let start = cal.date(from: DateComponents(year: year, month: 1, day: 1)),
              let range = cal.range(of: .day, in: .year, for: start) else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(String(year)).font(Theme.line(34)).foregroundStyle(Theme.ink)
                    Spacer()
                    Button { year -= 1 } label: { Image(systemName: "chevron.left") }
                    Button { year += 1 } label: { Image(systemName: "chevron.right") }
                        .disabled(year >= cal.component(.year, from: .now))
                }
                .foregroundStyle(Theme.ink)

                // 7 columns (Mon-Sun style weeks flow top-to-bottom).
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 14), spacing: 5) {
                    ForEach(days, id: \.self) { d in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(byDay[d]?.mood.color ?? Theme.ink.opacity(0.08))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                Text("\(entries.filter { cal.component(.year, from: $0.day) == year }.count) days kept")
                    .font(Theme.caption).foregroundStyle(Theme.quiet)
                Spacer()
            }
            .padding(28)
        }
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
