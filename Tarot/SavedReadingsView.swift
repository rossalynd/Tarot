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
    @State private var selectedReading: Reading? = nil
    @State private var showPopover: Bool = false

    var body: some View {
        List {
            ForEach(readings) { reading in
                NavigationLink(destination: SavedReadingPopover(reading: reading)) {
                    VStack(alignment: .leading) {
                        Text("Date: \(reading.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.headline)
                        Text("Notes: \(reading.notes.isEmpty ? "No notes available" : reading.notes)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            // Enable swipe-to-delete
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




import SwiftUI
import SwiftData

struct SavedReadingPopover: View {
    @Bindable var reading: Reading
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    

    var body: some View {
        VStack {
            Text("Reading Details")
                .font(.headline)
                .padding()
            Text(reading.date.formatted(.dateTime))

            // Display cards horizontally
            ScrollView(.horizontal) {
                HStack {
                    ForEach(reading.cardsChosen, id: \.id) { card in
                        CardView(card: card, isFaceUp: true).padding()
                    }
                }
            }
            .padding()

            // Editable Notes Section
            Text("Notes:")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)

            TextEditor(text: $reading.notes)
                .frame(height: 50)
                .border(Color.gray, width: 1)
                .padding()

            // Save Button
            Button("Save Changes") {
                do {
                    try modelContext.save()
                    dismiss() // Dismiss the popover
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
