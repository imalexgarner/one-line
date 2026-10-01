import SwiftUI

enum Theme {
    static let paper = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.085, blue: 0.08, alpha: 1)
            : UIColor(red: 0.975, green: 0.96, blue: 0.93, alpha: 1)
    })
    static let ink = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.91, blue: 0.87, alpha: 1)
            : UIColor(red: 0.13, green: 0.12, blue: 0.11, alpha: 1)
    })
    static let quiet = ink.opacity(0.5)

    /// Horizontal page margin shared by every screen.
    static let margin: CGFloat = 28
    static let title = line(30)

    static func line(_ size: CGFloat = 26) -> Font { .system(size: size, weight: .regular, design: .serif) }
    static let caption = Font.system(.footnote, design: .serif).italic()
}
