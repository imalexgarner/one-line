import SwiftUI

/// First-run welcome: what the app is, then an optional daily reminder. Calls `onFinish` when done.
struct WelcomeView: View {
    var onFinish: () -> Void

    @AppStorage(Reminder.enabledKey) private var reminderEnabled = false
    @AppStorage(Reminder.minutesKey) private var reminderMinutes = Reminder.defaultMinutes
    @State private var step = 0
    @State private var time = Calendar.current.date(from: Reminder.components(minutes: Reminder.defaultMinutes)) ?? .now

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            Group {
                if step == 0 {
                    OnboardingPage(
                        illustration: "nc-improve-signup-experience",
                        title: "One line a day.",
                        message: "Keep one small thing from every day. Come back tomorrow, and a year from now, to see what you wrote."
                    ) {
                        PrimaryButton("Begin") { withAnimation(.smooth) { step = 1 } }
                    }
                } else {
                    OnboardingPage(
                        title: "A gentle nudge?",
                        message: "Pick a time and we'll remind you once a day. It never leaves your device."
                    ) {
                        DatePicker("Reminder time", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel).labelsHidden()
                            .frame(maxWidth: .infinity)
                    } actions: {
                        PrimaryButton("Remind me") { Task { await enableReminder() } }
                        QuietButton("Not now") { onFinish() }
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)))
        }
    }

    private func enableReminder() async {
        let c = Calendar.current.dateComponents([.hour, .minute], from: time)
        let minutes = (c.hour ?? 21) * 60 + (c.minute ?? 0)
        let granted = await Reminder.requestAuthorization()
        reminderEnabled = granted
        if granted {
            reminderMinutes = minutes
            await Reminder.schedule(minutes: minutes)
        }
        onFinish()
    }
}

#if DEBUG
#Preview {
    WelcomeView {}
}
#endif
