import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.day, order: .reverse) private var entries: [Entry]

    @State private var draft = ""
    @State private var mood: Mood = .calm
    @FocusState private var focused: Bool

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var todays: Entry? { entries.first { $0.day == today } }
    private var memory: Resurfaced? { Resurfacing.pick(for: today, from: entries) }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 36) {
                    header
                    if let todays { written(todays) } else { composer }
                    if let memory, todays != nil || entries.count > 0 { memoryCard(memory) }
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(today.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(Theme.caption).foregroundStyle(Theme.quiet)
            Text(todays == nil ? "What's one thing from today?" : "Kept.")
                .font(Theme.line(30)).foregroundStyle(Theme.ink)
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField("One line…", text: $draft, axis: .vertical)
                .font(Theme.line()).foregroundStyle(Theme.ink)
                .lineLimit(1...4)
                .focused($focused)
                .submitLabel(.done)
                .onChange(of: draft) { _, new in
                    // One line: no manual line breaks, gentle length cap.
                    let cleaned = new.replacingOccurrences(of: "\n", with: " ")
                    draft = String(cleaned.prefix(140))
                }
            HStack(spacing: 14) {
                ForEach(Mood.allCases) { m in
                    Circle().fill(m.color)
                        .frame(width: mood == m ? 38 : 30, height: mood == m ? 38 : 30)
                        .overlay(Circle().stroke(Theme.ink, lineWidth: mood == m ? 2 : 0).padding(-4))
                        .onTapGesture { withAnimation(.snappy) { mood = m } }
                        .accessibilityLabel(m.name)
                        .accessibilityAddTraits(mood == m ? .isSelected : [])
                }
            }
            Button(action: save) {
                Text("Keep it").font(.system(.body, design: .serif).weight(.semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent).tint(Theme.ink)
            .foregroundStyle(Theme.paper)
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private func written(_ e: Entry) -> some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 3).fill(e.mood.color).frame(width: 6)
            Text(e.text).font(Theme.line()).foregroundStyle(Theme.ink)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func memoryCard(_ m: Resurfaced) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(m.label.uppercased())
                .font(.system(.caption2, design: .serif).weight(.semibold)).tracking(1.5)
                .foregroundStyle(Theme.quiet)
            Text(m.entry.text).font(Theme.line(22)).foregroundStyle(Theme.ink)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(m.entry.mood.color.opacity(0.18), in: RoundedRectangle(cornerRadius: 20))
    }

    private func save() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        focused = false
        withAnimation(.smooth) {
            context.insert(Entry(day: today, text: text, mood: mood))
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

#if DEBUG
#Preview("Empty") {
    TodayView().modelContainer(PreviewData.container(.empty))
}

#Preview("Memory + composer") {
    TodayView().modelContainer(PreviewData.container(.needsToday))
}

#Preview("Written today") {
    TodayView().modelContainer(PreviewData.container(.full))
}

#Preview("Dark") {
    TodayView()
        .modelContainer(PreviewData.container(.needsToday))
        .preferredColorScheme(.dark)
}
#endif
