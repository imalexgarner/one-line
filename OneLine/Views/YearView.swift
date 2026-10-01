import SwiftUI
import SwiftData

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
    @State private var selected: DayID?

    private struct DayID: Identifiable { let date: Date; var id: Date { date } }

    private var cal: Calendar { .current }
    private var today: Date { cal.startOfDay(for: .now) }
    private var byDay: [Date: Entry] { Dictionary(entries.map { ($0.day, $0) }, uniquingKeysWith: { first, _ in first }) }

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

            switch mode {
            case .year:
                TabView(selection: $yearPage) {
                    ForEach(years, id: \.self) { year in
                        YearGrid(year: year, byDay: byDay, today: today) { selected = DayID(date: $0) }
                            .tag(year)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            case .month:
                TabView(selection: $monthPage) {
                    ForEach(months, id: \.self) { month in
                        MonthGrid(month: month, byDay: byDay, today: today) { selected = DayID(date: $0) }
                            .tag(month)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background { Theme.paper.ignoresSafeArea() }
        .sheet(item: $selected) { DaySheet(day: $0.date) }
        .onChange(of: mode) { _, new in syncPages(to: new) }
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

// MARK: - Year: every day of one year, sized to fill the available space

private struct YearGrid: View {
    let year: Int
    let byDay: [Date: Entry]
    let today: Date
    let onSelect: (Date) -> Void

    private let spacing: CGFloat = 4

    private var days: [Date] {
        let cal = Calendar.current
        guard let start = cal.date(from: DateComponents(year: year, month: 1, day: 1)),
              let range = cal.range(of: .day, in: .year, for: start) else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    var body: some View {
        GeometryReader { geo in
            let days = days
            let fit = GridFit.best(count: days.count, width: geo.size.width, height: geo.size.height, spacing: spacing)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(fit.tile), spacing: spacing), count: fit.columns),
                      spacing: spacing) {
                ForEach(days, id: \.self) { day in
                    DayTile(day: day, entry: byDay[day], today: today, radius: max(2, fit.tile * 0.2), onSelect: onSelect)
                        .frame(width: fit.tile, height: fit.tile)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 16)
    }
}

// MARK: - Month: a calendar with day numbers

private struct MonthGrid: View {
    let month: Date
    let byDay: [Date: Entry]
    let today: Date
    let onSelect: (Date) -> Void

    private let spacing: CGFloat = 6
    private let headerHeight: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let cells = MonthLayout.cells(for: month)
            let rows = max(1, cells.count / 7)
            let colWidth = (geo.size.width - 6 * spacing) / 7
            let availableHeight = geo.size.height - headerHeight - spacing
            let cellHeight = min(colWidth * 1.35, (availableHeight - CGFloat(rows - 1) * spacing) / CGFloat(rows))

            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    ForEach(Array(MonthLayout.weekdaySymbols().enumerated()), id: \.offset) { _, symbol in
                        Text(symbol).font(Theme.caption).foregroundStyle(Theme.quiet)
                            .frame(width: colWidth, height: headerHeight)
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(colWidth), spacing: spacing), count: 7), spacing: spacing) {
                    ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                        if let day {
                            DayTile(day: day, entry: byDay[day], today: today, radius: 10, showsNumber: true, onSelect: onSelect)
                                .frame(width: colWidth, height: cellHeight)
                        } else {
                            Color.clear.frame(width: colWidth, height: cellHeight)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 16)
    }
}

// MARK: - One day

private struct DayTile: View {
    let day: Date
    let entry: Entry?
    let today: Date
    var radius: CGFloat = 4
    var showsNumber = false
    let onSelect: (Date) -> Void

    var body: some View {
        Button { onSelect(day) } label: {
            RoundedRectangle(cornerRadius: radius)
                .fill(entry?.mood.color ?? Theme.ink.opacity(0.08))
                .overlay {
                    if day == today { RoundedRectangle(cornerRadius: radius).stroke(Theme.ink, lineWidth: 1.5) }
                }
                .overlay {
                    if showsNumber {
                        Text("\(Calendar.current.component(.day, from: day))")
                            .font(.system(.callout, design: .serif).weight(entry == nil ? .regular : .semibold))
                            .foregroundStyle(entry?.mood.onColor ?? Theme.quiet)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(day > today)
        .accessibilityLabel(day.formatted(.dateTime.month(.wide).day()))
        .accessibilityValue(entry.map { "\($0.mood.name): \($0.text)" } ?? "No entry")
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
