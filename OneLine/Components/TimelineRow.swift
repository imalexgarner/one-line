import SwiftUI

/// One row of the timeline: a mood dot, a short date, and the line.
///
///     TimelineRow(day: entry.day, text: entry.text, mood: entry.mood)
struct TimelineRow: View {
    let day: Date
    let text: String
    let mood: Mood

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle().fill(mood.color).frame(width: 10, height: 10).padding(.top, 8)
            VStack(alignment: .leading, spacing: 4) {
                Text(day.formatted(.dateTime.weekday(.abbreviated).day()))
                    .font(Theme.caption).foregroundStyle(Theme.quiet)
                Text(text).font(Theme.entrySmall).foregroundStyle(Theme.ink)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 20) {
        TimelineRow(day: .now, text: "Cooked for friends.", mood: .warm)
        TimelineRow(day: .now.addingTimeInterval(-86_400), text: "Long call with Mum. She laughed the whole way through.", mood: .radiant)
    }
    .padding(28).background(Theme.paper)
}
#endif
