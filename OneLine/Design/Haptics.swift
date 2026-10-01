import UIKit

/// Tiny wrapper so views don't touch UIKit feedback generators directly.
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
