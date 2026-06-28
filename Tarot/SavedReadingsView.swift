//
//  SavedReadingsView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import SwiftUI
import SwiftData

struct SavedReadingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath

    @Query private var readings: [Reading]

    @State private var searchText = ""
    @State private var sortOrder: ReadingSortOrder = .newestFirst

    @State private var showFilters = false
    @State private var useStartDateFilter = false
    @State private var useEndDateFilter = false
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()

    @State private var collapsedMonths: Set<Date> = []

    private var filteredAndSortedReadings: [Reading] {
        let calendar = Calendar.current

        return readings
            .filter { reading in
                if useStartDateFilter {
                    let startOfStartDate = calendar.startOfDay(for: startDate)

                    if reading.date < startOfStartDate {
                        return false
                    }
                }

                if useEndDateFilter {
                    let startOfEndDate = calendar.startOfDay(for: endDate)
                    let dayAfterEndDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate) ?? endDate

                    if reading.date >= dayAfterEndDate {
                        return false
                    }
                }

                guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return true
                }

                return reading.matchesSearch(searchText)
            }
            .sorted { first, second in
                switch sortOrder {
                case .newestFirst:
                    return first.date > second.date
                case .oldestFirst:
                    return first.date < second.date
                }
            }
    }

    private var groupedReadings: [ReadingMonthGroup] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: filteredAndSortedReadings) { reading in
            calendar.date(
                from: calendar.dateComponents([.year, .month], from: reading.date)
            ) ?? reading.date
        }

        return grouped
            .map { monthDate, readings in
                ReadingMonthGroup(
                    monthDate: monthDate,
                    readings: readings.sorted { first, second in
                        switch sortOrder {
                        case .newestFirst:
                            return first.date > second.date
                        case .oldestFirst:
                            return first.date < second.date
                        }
                    }
                )
            }
            .sorted { first, second in
                switch sortOrder {
                case .newestFirst:
                    return first.monthDate > second.monthDate
                case .oldestFirst:
                    return first.monthDate < second.monthDate
                }
            }
    }

    var body: some View {
        ZStack {
            savedReadingsBackground

            List {
                if filteredAndSortedReadings.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(groupedReadings) { group in
                        Section {
                            MonthHeaderView(
                                group: group,
                                isCollapsed: collapsedMonths.contains(group.monthDate)
                            ) {
                                toggleMonth(group.monthDate)
                            }
                            .listRowInsets(EdgeInsets(top: 12, leading: 18, bottom: 6, trailing: 18))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                            if !collapsedMonths.contains(group.monthDate) {
                                ForEach(group.readings) { reading in
                                    NavigationLink {
                                        SavedReadingView(reading: reading)
                                    } label: {
                                        SavedReadingRow(reading: reading)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteReading(reading)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Saved Readings")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search notes or dates"
        )
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $sortOrder) {
                        ForEach(ReadingSortOrder.allCases) { order in
                            Text(order.title)
                                .tag(order)
                        }
                    }

                    Divider()

                    Button("Expand All") {
                        collapsedMonths.removeAll()
                    }

                    Button("Collapse All") {
                        collapsedMonths = Set(groupedReadings.map(\.monthDate))
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }

                Button {
                    showFilters = true
                } label: {
                    Image(systemName: activeFilterIcon)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            SavedReadingsFilterSheet(
                useStartDateFilter: $useStartDateFilter,
                useEndDateFilter: $useEndDateFilter,
                startDate: $startDate,
                endDate: $endDate
            )
        }
    }

    private var savedReadingsBackground: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.indigo.opacity(0.16),
                Color.purple.opacity(0.08),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay {
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.16))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .offset(x: -140, y: -260)

                Circle()
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 90)
                    .offset(x: 160, y: 260)
            }
        }
    }

    private var activeFilterIcon: String {
        if useStartDateFilter || useEndDateFilter {
            return "line.3.horizontal.decrease.circle.fill"
        } else {
            return "line.3.horizontal.decrease.circle"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("No Readings Found")
                .font(.headline)

            Text("Try changing your search or date filters.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 70)
    }

    private func toggleMonth(_ monthDate: Date) {
        if collapsedMonths.contains(monthDate) {
            collapsedMonths.remove(monthDate)
        } else {
            collapsedMonths.insert(monthDate)
        }
    }

    private func deleteReading(_ reading: Reading) {
        modelContext.delete(reading)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete reading: \(error.localizedDescription)")
        }
    }
}

// MARK: - Month Header

private struct MonthHeaderView: View {
    let group: ReadingMonthGroup
    let isCollapsed: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.monthTitle)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)

                    Text("\(group.readings.count) \(group.readings.count == 1 ? "reading" : "readings")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
            }
            .padding(.horizontal, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Saved Reading Row

private struct SavedReadingRow: View {
    let reading: Reading

    private var hasRune: Bool {
        if let rune = reading.rune {
            return !rune.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        return false
    }

    private var hasPattern: Bool {
        !reading.hexagramLines.isEmpty
    }

    private var hasNotes: Bool {
        !reading.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reading.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(summaryLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if !reading.cardNames.isEmpty {
                Text(reading.cardNames.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }

            Text(notesPreview)
                .font(.subheadline)
                .foregroundStyle(hasNotes ? .secondary : .tertiary)
                .italic(!hasNotes)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.indigo.opacity(0.65))
                .frame(width: 4)
                
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        }
    }

    private var summaryLine: String {
        var pieces: [String] = []

        if hasRune {
            pieces.append("Rune")
        }

        if hasPattern {
            pieces.append("iChing")
        }

        if pieces.isEmpty {
            return "Tarot reading"
        } else {
            return pieces.joined(separator: " • ")
        }
    }

    private var notesPreview: String {
        let trimmedNotes = reading.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedNotes.isEmpty {
            return "No notes"
        } else {
            return trimmedNotes
        }
    }
}

// MARK: - Filter Sheet

private struct SavedReadingsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var useStartDateFilter: Bool
    @Binding var useEndDateFilter: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Filter from date", isOn: $useStartDateFilter)

                    if useStartDateFilter {
                        DatePicker(
                            "Start Date",
                            selection: $startDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section {
                    Toggle("Filter until date", isOn: $useEndDateFilter)

                    if useEndDateFilter {
                        DatePicker(
                            "End Date",
                            selection: $endDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section {
                    Button("Clear Filters") {
                        useStartDateFilter = false
                        useEndDateFilter = false
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Filter Readings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Supporting Types

private enum ReadingSortOrder: String, CaseIterable, Identifiable {
    case newestFirst
    case oldestFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newestFirst:
            return "Newest First"
        case .oldestFirst:
            return "Oldest First"
        }
    }
}

private struct ReadingMonthGroup: Identifiable {
    let monthDate: Date
    let readings: [Reading]

    var id: Date { monthDate }

    var monthTitle: String {
        monthDate.formatted(.dateTime.month(.wide).year())
    }
}

// MARK: - Reading Search Helper

private extension Reading {
    private static let numericDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    func matchesSearch(_ searchText: String) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return true
        }

        let searchableText = [
            notes,
            cardNames.joined(separator: " "),
            rune ?? "",
            date.formatted(date: .abbreviated, time: .shortened),
            date.formatted(date: .complete, time: .omitted),
            date.formatted(.dateTime.month(.wide).day().year()),
            date.formatted(.dateTime.month(.abbreviated).day().year()),
            Self.numericDateFormatter.string(from: date)
        ]
        .joined(separator: " ")

        return searchableText.localizedCaseInsensitiveContains(query)
    }
}
