import SwiftUI

/// One day as a tappable tile: filled with the mood colour when kept, faint when blank,
/// outlined when it is today, and disabled in the future.
///
///     DayTile(day: day, mark: marks[day], today: today) { open($0) }
///     DayTile(day: day, mark: marks[day], today: today, cornerRadius: 10, showsNumber: true) { open($0) }
struct DayTile: View {
    let day: Date
    var mark: DayMark?
    let today: Date
    var cornerRadius: CGFloat = 4
    var showsNumber = false
    let onSelect: (Date) -> Void

    var body: some View {
        Button { onSelect(day) } label: {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(mark?.mood.color ?? Theme.ink.opacity(0.08))
                .overlay {
                    if day == today { RoundedRectangle(cornerRadius: cornerRadius).stroke(Theme.ink, lineWidth: 1.5) }
                }
                .overlay {
                    if showsNumber {
                        Text("\(Calendar.current.component(.day, from: day))")
                            .font(Theme.number.weight(mark == nil ? .regular : .semibold))
                            .foregroundStyle(mark?.mood.onColor ?? Theme.quiet)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)   // it has to fit inside a tile
                    }
                }
        }
        .buttonStyle(PressableButtonStyle(scale: 0.88))
        .disabled(day > today)
        .accessibilityLabel(day.formatted(.dateTime.month(.wide).day()))
        .accessibilityValue(mark.map { "\($0.mood.name): \($0.text)" } ?? "No entry")
    }
}

#if DEBUG
#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    func day(_ ago: Int) -> Date { cal.date(byAdding: .day, value: -ago, to: today)! }
    return HStack(spacing: 8) {
        DayTile(day: day(2), mark: DayMark(mood: .radiant, text: "x"), today: today, cornerRadius: 10, showsNumber: true) { _ in }
        DayTile(day: day(1), mark: DayMark(mood: .stormy, text: "x"), today: today, cornerRadius: 10, showsNumber: true) { _ in }
        DayTile(day: day(3), today: today, cornerRadius: 10, showsNumber: true) { _ in }
        DayTile(day: today, today: today, cornerRadius: 10, showsNumber: true) { _ in }
        DayTile(day: day(-1), today: today, cornerRadius: 10, showsNumber: true) { _ in }
    }
    .frame(height: 70).padding(28).background(Theme.paper)
}
#endif
