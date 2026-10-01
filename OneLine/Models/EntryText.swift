import Foundation

enum EntryText {
    static let maxLength = 140

    /// Applied while typing: one line, capped. Does not trim, so spaces between words survive.
    static func limit(_ raw: String) -> String {
        String(raw.replacingOccurrences(of: "\n", with: " ").prefix(maxLength))
    }

    /// Applied on save.
    static func final(_ raw: String) -> String {
        limit(raw).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
