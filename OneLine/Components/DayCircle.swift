import SwiftUI

/// One day as a tappable circle: solid mood colour with its number when kept, faint when blank,
/// ringed when it is today, outlined when it is the day the list is showing, and disabled in the future.
///
///     DayCircle(day: day, mark: marks[day], today: today, isFocused: day == focus) { select($0) }
struct DayCircle: View {
    let day: Date
    var mark: DayMark?
    let today: Date
    var isFocused = false
    let onSelect: (Date) -> Void

    private let size: CGFloat = 34

    var body: some View {
        Button { onSelect(day) } label: {
            ZStack {
                Circle().fill(mark?.mood.color ?? Theme.ink.opacity(day > today ? 0.04 : 0.08))
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(Theme.number.weight(mark == nil ? .regular : .semibold))
                    .foregroundStyle(mark?.mood.onColor ?? Theme.quiet.opacity(day > today ? 0.5 : 1))
            }
            .frame(width: size, height: size)
            .overlay { if day == today { Circle().stroke(Theme.ink, lineWidth: 1.5).padding(-3) } }
            .overlay { if isFocused && day != today { Circle().stroke(Theme.ink.opacity(0.35), lineWidth: 1.5).padding(-3) } }
            .dynamicTypeSize(...DynamicTypeSize.large)   // it has to fit inside the circle
            .frame(maxWidth: .infinity)
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
    return HStack(spacing: 0) {
        DayCircle(day: day(3), mark: DayMark(mood: .radiant, text: "x"), today: today) { _ in }
        DayCircle(day: day(2), mark: DayMark(mood: .stormy, text: "x"), today: today, isFocused: true) { _ in }
        DayCircle(day: day(1), today: today) { _ in }
        DayCircle(day: today, today: today) { _ in }
        DayCircle(day: day(-1), today: today) { _ in }
    }
    .padding(.horizontal, 20).padding(.vertical, 28).background(Theme.paper)
}
#endif
