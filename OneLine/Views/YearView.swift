import SwiftUI
import SwiftData

/// The year at a glance: every day as a tile, swipe between years, or switch to a calendar per month.
struct YearView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case year = "Year", month = "Month"
        var id: String { rawValue }
    }

    @Query private var entries: [Entry]
    @State private var mode: Mode = {
        #if DEBUG
        UserDefaults.standard.integer(forKey: "debugMode") == 1 ? .month : .year
        #else
        .year
        #endif
    }()
    @State private var yearPage: Int = {
        let year = Calendar.current.component(.year, from: .now)
        #if DEBUG
        return year - UserDefaults.standard.integer(forKey: "debugYearsBack")   // `-debugYearsBack 1` starts on last year
        #else
        return year
        #endif
    }()
    @State private var monthPage: Date = {
        let start = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
        #if DEBUG
        let back = UserDefaults.standard.integer(forKey: "debugMonthsBack")   // `-debugMonthsBack 1` starts on last month
        return Calendar.current.date(byAdding: .month, value: -back, to: start) ?? start
        #else
        return start
        #endif
    }()
    @State private var selected: DayID? = {
        #if DEBUG
        // `-debugOpenDaysAgo 3` opens that day's sheet on launch, for checking the sheet layout.
        if let raw = UserDefaults.standard.string(forKey: "debugOpenDaysAgo"), let ago = Int(raw),
           let date = Calendar.current.date(byAdding: .day, value: -ago, to: Calendar.current.startOfDay(for: .now)) {
            return DayID(date: date)
        }
        #endif
        return nil
    }()

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private var cal: Calendar { .current }
    private var today: Date { cal.startOfDay(for: .now) }

    private var years: [Int] {
        let current = cal.component(.year, from: today)
        let first = entries.map { cal.component(.year, from: $0.day) }.min() ?? current
        // Always include the selected page, so the pager never drops the user's position
        // (e.g. while data is still loading, or after deleting the last line of a year).
        return Array(min(first, current, yearPage)...current)
    }

    private var months: [Date] {
        let thisMonth = cal.dateInterval(of: .month, for: today)?.start ?? today
        let earliest = entries.map(\.day).min().flatMap { cal.dateInterval(of: .month, for: $0)?.start } ?? thisMonth
        var result: [Date] = []
        var cursor = min(earliest, thisMonth, monthPage)
        while cursor <= thisMonth {
            result.append(cursor)
            guard let next = cal.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    private var keptCount: Int {
        switch mode {
        case .year: entries.filter { cal.component(.year, from: $0.day) == yearPage }.count
        case .month: entries.filter { cal.isDate($0.day, equalTo: monthPage, toGranularity: .month) }.count
        }
    }

    var body: some View {
        let marks = DayMark.marks(from: entries)
        VStack(spacing: 0) {
            ScreenHeader(
                eyebrow: "\(keptCount) \(keptCount == 1 ? "day" : "days") kept",
                title: mode == .year ? String(yearPage) : monthPage.formatted(.dateTime.month(.wide).year())
            )
            Picker("View", selection: $mode.animation(.snappy)) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Theme.margin)
            .padding(.bottom, 20)

            Group {
                switch mode {
                case .year:
                    TabView(selection: $yearPage) {
                        ForEach(years, id: \.self) { year in
                            YearGrid(year: year, marks: marks, today: today, onSelect: open)
                                .tag(year)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .sensoryFeedback(.selection, trigger: yearPage)
                    .transition(.opacity)
                case .month:
                    TabView(selection: $monthPage) {
                        ForEach(months, id: \.self) { month in
                            MonthPage(month: month, marks: marks, today: today, onSelect: open)
                                .tag(month)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .sensoryFeedback(.selection, trigger: monthPage)
                    .transition(.opacity)
                }
            }
            .overlay {
                if entries.isEmpty {
                    EmptyState("Your year starts today", message: "Write your first line and its tile fills with colour.")
                        .padding(24)
                        .background(Theme.paper, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.ink.opacity(0.08)))
                        .padding(Theme.margin)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { Theme.paper.ignoresSafeArea() }
        .sheet(item: $selected) { DaySheet(day: $0.date) }
        .onChange(of: mode) { _, new in syncPages(to: new) }
    }

    private func open(_ day: Date) {
        Haptics.selection()
        selected = DayID(date: day)
    }

    /// Keep the two pagers pointing at the same moment when the user flips between them.
    private func syncPages(to mode: Mode) {
        switch mode {
        case .month:
            if cal.component(.year, from: monthPage) != yearPage,
               let match = months.last(where: { cal.component(.year, from: $0) == yearPage }) {
                monthPage = match
            }
        case .year:
            let y = cal.component(.year, from: monthPage)
            if years.contains(y) { yearPage = y }
        }
    }
}

#if DEBUG
#Preview("Year") {
    YearView().modelContainer(PreviewData.container(.full))
}

#Preview("Empty") {
    YearView().modelContainer(PreviewData.container(.empty))
}

#Preview("Dark") {
    YearView()
        .modelContainer(PreviewData.container(.full))
        .preferredColorScheme(.dark)
}
#endif
