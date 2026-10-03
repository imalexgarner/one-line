import SwiftUI

/// A month calendar with its mood summary underneath. At normal text sizes it fills the space it is
/// given; at accessibility sizes, where that can't fit, it scrolls instead of overlapping.
///
///     MonthPage(month: monthStart, marks: marks, today: today) { day in open(day) }
struct MonthPage: View {
    let month: Date
    let marks: [Date: DayMark]
    let today: Date
    let onSelect: (Date) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    private var summary: some View {
        MoodSummary(counts: MoodCounts.counts(in: marks, month: month))
            .padding(.horizontal, Theme.margin)
            .padding(.bottom, 16)
    }

    var body: some View {
        if typeSize.isAccessibilitySize {
            ScrollView {
                VStack(spacing: 16) {
                    MonthGrid(month: month, marks: marks, today: today, onSelect: onSelect)
                        .frame(height: 460)
                    summary
                }
            }
        } else {
            VStack(spacing: 0) {
                MonthGrid(month: month, marks: marks, today: today, onSelect: onSelect)
                summary
            }
        }
    }
}

#if DEBUG
#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    let month = cal.dateInterval(of: .month, for: today)!.start
    var marks: [Date: DayMark] = [:]
    for d in 0..<28 {
        if let day = cal.date(byAdding: .day, value: d, to: month), day < today, d % 3 != 0 {
            marks[day] = DayMark(mood: Mood.allCases[d % Mood.allCases.count], text: "Sample")
        }
    }
    return MonthPage(month: month, marks: marks, today: today) { _ in }.background(Theme.paper)
}
#endif
