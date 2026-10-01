import CoreGraphics

/// Picks the column count that makes square tiles as large as possible while the whole grid still
/// fits inside a given width and height. This is what lets the Year view adapt to any screen
/// without scrolling.
struct GridFit: Equatable {
    let columns: Int
    let tile: CGFloat


    static func best(count: Int, width: CGFloat, height: CGFloat, spacing: CGFloat) -> GridFit {
        guard count > 0, width > 0, height > 0 else { return GridFit(columns: 1, tile: 0) }
        var best = GridFit(columns: 1, tile: 0)
        for columns in 1...count {
            let rows = (count + columns - 1) / columns
            let byWidth = (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
            let byHeight = (height - CGFloat(rows - 1) * spacing) / CGFloat(rows)
            let tile = min(byWidth, byHeight).rounded(.down)
            if tile > best.tile { best = GridFit(columns: columns, tile: tile) }
        }
        return best
    }

    func rows(for count: Int) -> Int { columns == 0 ? 0 : (count + columns - 1) / columns }
}
