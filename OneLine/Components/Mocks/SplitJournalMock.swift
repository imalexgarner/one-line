#if DEBUG
import SwiftUI

/// Design mock only (not wired to data): the combined calendar + journal screen.
/// A black seam runs edge to edge between two cards whose facing corners are rounded. The calendar
/// card is a week strip (circles); the list below is the primary element. Drag the handle to resize;
/// it snaps to 1 row, 2 rows or a full month.
///
///     SplitJournalMock()
struct SplitJournalMock: View {
    private let rowPitch: CGFloat = 42          // 34pt circle + 8pt gap
    private let seam: CGFloat = 12              // the black bar between the cards
    private let radius: CGFloat = 24
    private let detents = [1, 2, 5]             // rows of the calendar card

    @State private var rows = 2
    @State private var drag: CGFloat = 0

    private func height(forRows r: Int) -> CGFloat { CGFloat(r) * rowPitch + 8 }

    private var topHeight: CGFloat {
        let proposed = height(forRows: rows) + drag
        return min(max(proposed, height(forRows: 1)), height(forRows: 5))
    }

    private var topShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: radius, bottomTrailing: radius), style: .continuous)
    }
    private var bottomShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(cornerRadii: .init(topLeading: radius, topTrailing: radius), style: .continuous)
    }

    var body: some View {
        VStack(spacing: 0) {
            calendarCard.frame(height: topHeight)
            handle
            listCard
        }
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: Calendar card

    private var calendarCard: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(0..<35, id: \.self) { i in
                    MockCircle(day: i)
                }
            }
            .padding(.horizontal, Theme.margin - 6)
            .padding(.vertical, 8)
        }
        .background(Theme.paper, in: topShape)
        .clipShape(topShape)
    }

    // MARK: Seam with grabber

    private var handle: some View {
        Color.black
            .frame(height: seam)
            .overlay { Capsule().fill(.white.opacity(0.35)).frame(width: 36, height: 4) }
            .overlay {
                Color.clear.frame(height: 44).contentShape(Rectangle())   // generous hit area
                    .gesture(
                        DragGesture()
                            .onChanged { drag = $0.translation.height }
                            .onEnded { value in
                                let proposed = topHeight
                                let nearest = detents.min {
                                    abs(height(forRows: $0) - proposed) < abs(height(forRows: $1) - proposed)
                                } ?? 2
                                withAnimation(.snappy) { rows = nearest; drag = 0 }
                            }
                    )
            }
            .accessibilityLabel("Resize calendar")
            .accessibilityValue("\(rows) rows")
            .accessibilityAdjustableAction { direction in
                guard let i = detents.firstIndex(of: rows) else { return }
                let next = direction == .increment ? min(i + 1, detents.count - 1) : max(i - 1, 0)
                withAnimation(.snappy) { rows = detents[next] }
            }
    }

    // MARK: List card

    private var listCard: some View {
        List {
            ForEach(0..<14, id: \.self) { i in
                TimelineRow(
                    day: Calendar.current.date(byAdding: .day, value: -i, to: .now) ?? .now,
                    text: MockData.lines[i % MockData.lines.count],
                    mood: Mood.allCases[i % Mood.allCases.count]
                )
                .listRowBackground(Theme.paper)
                .listRowSeparatorTint(Theme.ink.opacity(0.08))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.paper, in: bottomShape)
        .clipShape(bottomShape)
    }
}

private enum MockData {
    static let lines = [
        "Slow coffee on the balcony. Nowhere to be.",
        "Rain all day, but the soup was perfect.",
        "Long call with Mum. She laughed the whole way through.",
        "Everything felt a bit grey.",
        "Cooked for friends.",
    ]
}

/// A day as a circle: solid mood colour, or a photo inside a mood-coloured ring. Blank days are faint.
private struct MockCircle: View {
    let day: Int
    private let size: CGFloat = 34

    private var mood: Mood? { day % 5 == 3 ? nil : Mood.allCases[day % Mood.allCases.count] }
    private var hasPhoto: Bool { day % 4 == 1 }
    private var isToday: Bool { day == 17 }
    private var photoColors: [Color] { [[.orange, .pink], [.mint, .teal], [.indigo, .blue]][day % 3] }

    var body: some View {
        ZStack {
            if let mood {
                Circle().fill(mood.color)
                if hasPhoto {
                    Circle().fill(LinearGradient(colors: photoColors, startPoint: .top, endPoint: .bottom)).padding(2.5)
                } else {
                    Text("\(day + 1)").font(Theme.number.weight(.semibold)).foregroundStyle(mood.onColor)
                }
            } else {
                Circle().fill(Theme.ink.opacity(0.08))
                Text("\(day + 1)").font(Theme.number).foregroundStyle(Theme.quiet)
            }
        }
        .frame(width: size, height: size)
        .overlay { if isToday { Circle().stroke(Theme.ink, lineWidth: 1.5).padding(-3) } }
        .dynamicTypeSize(...DynamicTypeSize.large)
    }
}

#Preview("Split journal") { SplitJournalMock() }
#Preview("Split journal dark") { SplitJournalMock().preferredColorScheme(.dark) }
#endif
