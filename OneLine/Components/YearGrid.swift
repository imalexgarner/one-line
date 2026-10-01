import SwiftUI

/// Every day of one year as small tiles, sized to fill whatever space it is given (no scrolling).
///
///     YearGrid(year: 2026, marks: marks, today: today) { day in open(day) }
struct YearGrid: View {
    let year: Int
    let marks: [Date: DayMark]
    let today: Date
    var spacing: CGFloat = 4
    let onSelect: (Date) -> Void

    private var days: [Date] {
        let cal = Calendar.current
        guard let start = cal.date(from: DateComponents(year: year, month: 1, day: 1)),
              let range = cal.range(of: .day, in: .year, for: start) else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    var body: some View {
        GeometryReader { geo in
            let days = days
            let fit = GridFit.best(count: days.count, width: geo.size.width, height: geo.size.height, spacing: spacing)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(fit.tile), spacing: spacing), count: fit.columns),
                      spacing: spacing) {
                ForEach(days, id: \.self) { day in
                    DayTile(day: day, mark: marks[day], today: today,
                            cornerRadius: max(2, fit.tile * 0.2), onSelect: onSelect)
                        .frame(width: fit.tile, height: fit.tile)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 16)
    }
}

#if DEBUG
#Preview("Filled") {
    let marks = YearGridPreview.marks
    YearGrid(year: Calendar.current.component(.year, from: .now), marks: marks, today: Calendar.current.startOfDay(for: .now)) { _ in }
        .frame(height: 560).background(Theme.paper)
}

#Preview("Short") {
    YearGrid(year: 2026, marks: [:], today: Calendar.current.startOfDay(for: .now)) { _ in }
        .frame(height: 360).background(Theme.paper)
}

private enum YearGridPreview {
    static var marks: [Date: DayMark] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        var result: [Date: DayMark] = [:]
        for ago in 1..<200 where ago % 4 != 0 {
            if let d = cal.date(byAdding: .day, value: -ago, to: today) {
                result[d] = DayMark(mood: Mood.allCases[ago % Mood.allCases.count], text: "Sample")
            }
        }
        return result
    }
}
#endif
