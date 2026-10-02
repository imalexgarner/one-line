import SwiftUI

/// S M T W T F S, in the calendar's own week order, lined up with a row of `DayCircle`s.
///
///     WeekdayHeader()
struct WeekdayHeader: View {
    /// Height of the row of letters.
    static let height: CGFloat = 20

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(MonthLayout.weekdaySymbols().enumerated()), id: \.offset) { _, symbol in
                Text(symbol).font(Theme.label).foregroundStyle(Theme.quiet)
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: Self.height)
        .padding(.horizontal, Theme.margin - 6)
        .accessibilityHidden(true)   // each circle already speaks its full date
    }
}

#if DEBUG
#Preview {
    WeekdayHeader().padding(.vertical, 20).background(Theme.paper)
}
#endif
