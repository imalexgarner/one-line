import Foundation
import UserNotifications

/// The daily "write your line" nudge. A single repeating local notification; nothing leaves the device.
enum Reminder {
    static let identifier = "daily-reminder"
    static let defaultMinutes = 21 * 60   // 9pm
    static let enabledKey = "reminderEnabled"
    static let minutesKey = "reminderMinutes"

    static func components(minutes: Int) -> DateComponents {
        DateComponents(hour: minutes / 60, minute: minutes % 60)
    }

    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func isAuthorized() async -> Bool {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    static func schedule(minutes: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "OneLine"
        content.body = "What's one thing from today?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components(minutes: minutes), repeats: true)
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
