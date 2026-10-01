import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage(Reminder.enabledKey) private var enabled = false
    @AppStorage(Reminder.minutesKey) private var minutes = Reminder.defaultMinutes
    @Query private var entries: [Entry]
    @State private var denied = false
    @Environment(\.openURL) private var openURL

    private var reminderTime: Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: Reminder.components(minutes: minutes)) ?? .now },
            set: {
                let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                minutes = (c.hour ?? 21) * 60 + (c.minute ?? 0)
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Daily reminder", isOn: Binding(get: { enabled }, set: { on in Task { await setEnabled(on) } }))
                    if enabled {
                        DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                    }
                    if denied {
                        Button("Notifications are off. Open Settings.") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                        }
                        .font(.footnote)
                    }
                } header: { Text("Reminder") } footer: {
                    Text("A quiet nudge at the same time each day. It never leaves your device.")
                }

                Section("Your journal") {
                    LabeledContent("Lines kept", value: "\(entries.count)")
                }
            }
            .font(.system(.body, design: .serif))
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("Settings")
            .task { await syncPermission() }
            .onChange(of: minutes) { _, new in
                if enabled { Task { await Reminder.schedule(minutes: new) } }
            }
        }
    }

    private func setEnabled(_ on: Bool) async {
        if on {
            let ok = await Reminder.requestAuthorization()
            enabled = ok
            denied = !ok
            if ok { await Reminder.schedule(minutes: minutes) }
        } else {
            enabled = false
            denied = false
            Reminder.cancel()
        }
    }

    /// If the user revoked permission in iOS Settings, reflect that here.
    private func syncPermission() async {
        guard enabled, !(await Reminder.isAuthorized()) else { return }
        enabled = false
        denied = true
        Reminder.cancel()
    }
}

#if DEBUG
#Preview {
    SettingsView().modelContainer(PreviewData.container(.full))
}

#Preview("Dark") {
    SettingsView().modelContainer(PreviewData.container(.full)).preferredColorScheme(.dark)
}
#endif
