#if DEBUG
import SwiftUI

/// Design mock only (not wired to data): two ways to show a photo on a Month-view tile while keeping
/// the mood colour. Real tiles are about 43 x 64pt (portrait), so sizes below match that.
///
///     PhotoTileMock(style: .mount, mood: .warm, day: 12)   // photo inset in a mood-coloured frame
///     PhotoTileMock(style: .dot, mood: .warm, day: 12)     // full-bleed photo, mood dot top right
struct PhotoTileMock: View {
    enum Style { case mount, dot }

    let style: Style
    let mood: Mood
    let day: Int
    var photoColors: [Color] = [.orange, .pink]

    private var photo: some View {
        LinearGradient(colors: photoColors, startPoint: .top, endPoint: .bottom)
            .overlay(Image(systemName: "mountain.2.fill").font(.title3).foregroundStyle(.white.opacity(0.5)))
    }

    private var number: some View {
        Text("\(day)")
            .font(Theme.number.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5).padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 14)
            .background(LinearGradient(colors: [.clear, .black.opacity(0.45)], startPoint: .top, endPoint: .bottom))
    }

    var body: some View {
        switch style {
        case .mount:
            RoundedRectangle(cornerRadius: 10).fill(mood.color)
                .overlay {
                    photo
                        .overlay(alignment: .bottom) { number }
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .padding(3)
                }
        case .dot:
            photo
                .overlay(alignment: .bottom) { number }
                .overlay(alignment: .topTrailing) {
                    Circle().fill(mood.color).frame(width: 8, height: 8)
                        .overlay(Circle().stroke(Theme.paper, lineWidth: 1.5))
                        .padding(5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct MockGrid: View {
    let style: PhotoTileMock.Style
    private let sets: [(Mood, [Color])] = [
        (.radiant, [.yellow, .orange]), (.warm, [.orange, .red]), (.calm, [.mint, .teal]),
        (.flat, [.gray, .brown]), (.heavy, [.indigo, .blue]), (.stormy, [.purple, .black]),
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(sets.enumerated()), id: \.offset) { i, set in
                PhotoTileMock(style: style, mood: set.0, day: i + 8, photoColors: set.1)
                    .frame(width: 43, height: 64)
            }
        }
    }
}

#Preview("Mount") { MockGrid(style: .mount).padding(28).background(Theme.paper) }
#Preview("Dot") { MockGrid(style: .dot).padding(28).background(Theme.paper) }
#Preview("Mount dark") { MockGrid(style: .mount).padding(28).background(Theme.paper).preferredColorScheme(.dark) }
#Preview("Dot dark") { MockGrid(style: .dot).padding(28).background(Theme.paper).preferredColorScheme(.dark) }
#endif
