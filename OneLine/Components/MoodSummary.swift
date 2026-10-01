import SwiftUI

/// How a period felt: a headline ("Mostly calm"), a proportional colour bar, and a legend.
///
///     MoodSummary(counts: MoodCounts.counts(in: marks, month: month))
struct MoodSummary: View {
    let counts: [Mood: Int]

    /// Legend column width grows with text size, so labels never break mid-word.
    @ScaledMetric(relativeTo: .callout) private var legendColumn: CGFloat = 96

    private var ordered: [(mood: Mood, count: Int)] {
        Mood.allCases.compactMap { m in (counts[m] ?? 0) > 0 ? (m, counts[m] ?? 0) : nil }
    }
    private var total: Int { ordered.reduce(0) { $0 + $1.count } }

    var body: some View {
        if let top = MoodCounts.dominant(counts) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Mostly \(top.name.lowercased())").font(Theme.entrySmall).foregroundStyle(Theme.ink)
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(ordered, id: \.mood) { item in
                            Capsule().fill(item.mood.color)
                                .frame(width: max(6, (geo.size.width - 2 * CGFloat(ordered.count - 1)) * CGFloat(item.count) / CGFloat(total)))
                        }
                    }
                }
                .frame(height: 12)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: legendColumn), alignment: .leading)], alignment: .leading, spacing: 6) {
                    ForEach(ordered, id: \.mood) { item in
                        HStack(spacing: 6) {
                            Circle().fill(item.mood.color).frame(width: 8, height: 8)
                            Text("\(item.count) \(item.mood.name)").font(Theme.caption).foregroundStyle(Theme.quiet)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Mostly \(top.name.lowercased()). " + ordered.map { "\($0.count) \($0.mood.name)" }.joined(separator: ", "))
        } else {
            Text("Nothing kept this month.").font(Theme.caption).foregroundStyle(Theme.quiet)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview("Mixed") {
    MoodSummary(counts: [.calm: 9, .warm: 6, .radiant: 4, .flat: 3, .heavy: 1, .stormy: 1])
        .padding(28).background(Theme.paper)
}

#Preview("Empty") {
    MoodSummary(counts: [:]).padding(28).background(Theme.paper)
}
#endif
