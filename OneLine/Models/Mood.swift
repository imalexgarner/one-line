import SwiftUI

/// Six curated colours. The mood *is* the colour: it paints the year grid.
enum Mood: Int, CaseIterable, Identifiable, Codable {
    case radiant, warm, calm, flat, heavy, stormy

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .radiant: "Radiant"
        case .warm: "Warm"
        case .calm: "Calm"
        case .flat: "Flat"
        case .heavy: "Heavy"
        case .stormy: "Stormy"
        }
    }

    var color: Color {
        switch self {
        case .radiant: Color(red: 0.96, green: 0.76, blue: 0.27)
        case .warm: Color(red: 0.93, green: 0.55, blue: 0.38)
        case .calm: Color(red: 0.49, green: 0.72, blue: 0.62)
        case .flat: Color(red: 0.72, green: 0.70, blue: 0.66)
        case .heavy: Color(red: 0.43, green: 0.50, blue: 0.69)
        case .stormy: Color(red: 0.36, green: 0.31, blue: 0.47)
        }
    }
}
