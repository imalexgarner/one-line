import SwiftUI

enum Theme {
    // MARK: Colour

    static let paper = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.085, blue: 0.08, alpha: 1)
            : UIColor(red: 0.975, green: 0.96, blue: 0.93, alpha: 1)
    })
    static let inkUI = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.91, blue: 0.87, alpha: 1)
            : UIColor(red: 0.13, green: 0.12, blue: 0.11, alpha: 1)
    }
    static let ink = Color(uiColor: inkUI)
    static let quiet = ink.opacity(0.5)

    // MARK: Layout

    /// Horizontal page margin shared by every screen and sheet.
    static let margin: CGFloat = 28

    // MARK: Type scale
    //
    // Serif is for the writing and for titles; everything that supports it is upright sans.
    // Every style is a text style, so all of them follow Dynamic Type.

    static let title = Font.system(.title, design: .serif)
    /// The line you write: the editor, a kept line.
    static let entry = Font.system(.title2, design: .serif)
    /// A line shown smaller: memory card, timeline row.
    static let entrySmall = Font.system(.title3, design: .serif)
    /// Row text in Settings: upright sans, not serif.
    static let body = Font.system(.body)
    static let button = Font.system(.body).weight(.semibold)
    /// Day numbers in the calendar.
    static let number = Font.system(.callout, design: .serif)
    /// Supporting text: eyebrows, dates, weekday headings, hints.
    static let caption = Font.system(.callout)
    /// Small uppercase labels, e.g. "1 YEAR AGO TODAY".
    static let label = Font.system(.caption).weight(.semibold)
}
