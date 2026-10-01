import Foundation

enum MoodCounts {
    /// How many days of `month` were kept in each mood.
    static func counts(in marks: [Date: DayMark], month: Date, calendar: Calendar = .current) -> [Mood: Int] {
        var result: [Mood: Int] = [:]
        for (day, mark) in marks where calendar.isDate(day, equalTo: month, toGranularity: .month) {
            result[mark.mood, default: 0] += 1
        }
        return result
    }

    /// The most frequent mood; ties go to the earlier case so the answer is stable.
    static func dominant(_ counts: [Mood: Int]) -> Mood? {
        counts.filter { $0.value > 0 }.max { a, b in
            a.value != b.value ? a.value < b.value : a.key.rawValue > b.key.rawValue
        }?.key
    }
}
