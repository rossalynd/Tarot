//
//  SavedReadingsView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI
import SwiftData

struct SavedReadingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @Query private var readings: [Reading]

    var body: some View {
        List {
            ForEach(readings) { reading in
                NavigationLink(destination: SavedReadingPopover(reading: reading)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date: \(reading.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.headline)

                        Text("Cards: \(reading.cardNames.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        if let rune = reading.rune {
                            Text("Rune: \(rune)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if !reading.hexagramLines.isEmpty {
                            Text("Pattern: \(reading.hexagramLines.map(String.init).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text("Notes: \(reading.notes.isEmpty ? "No notes available" : reading.notes)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
            .onDelete(perform: deleteReading)
        }
        .navigationTitle("Saved Readings")
    }

    private func deleteReading(at offsets: IndexSet) {
        for index in offsets {
            let reading = readings[index]
            modelContext.delete(reading)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete reading: \(error.localizedDescription)")
        }
    }
}

struct SavedReadingPopover: View {
    @Bindable var reading: Reading
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Reading Details")
                    .font(.headline)

                Text(reading.date.formatted(.dateTime))

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(reading.cardNames, id: \.self) { cardName in
                            CardView(card: Card(name: cardName), isFaceUp: true)
                                .frame(width: 90, height: 150)
                        }
                    }
                }

                if !reading.hexagramLines.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pattern")
                            .font(.subheadline)

                        HexagramDisplayView(lines: reading.hexagramLines)
                    }
                }

                if let rune = reading.rune {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rune")
                            .font(.subheadline)

                        Text(rune)
                            .font(.system(size: 42))
                    }
                }

                Text("Notes:")
                    .font(.subheadline)

                TextEditor(text: $reading.notes)
                    .frame(height: 80)
                    .border(Color.gray, width: 1)

                Button("Save Changes") {
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        print("Failed to save changes: \(error.localizedDescription)")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}
