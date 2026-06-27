//
//  SavedReadingView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI
import SwiftData

struct SavedReadingView: View {
    @Bindable var reading: Reading
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(reading.cardNames, id: \.self) { cardName in
                            CardView(card: Card(name: cardName), isFaceUp: true)
                                .frame(width: 90, height: 150)
                        }
                    }
                }
                .padding(.vertical, 5)

                if !reading.hexagramLines.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pattern")
                            .font(.headline)

                        HexagramDisplayView(lines: reading.hexagramLines)
                    }
                }

                if let rune = reading.rune {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rune")
                            .font(.headline)

                        Text(rune)
                            .font(.system(size: 42))
                    }
                }

                Text("Notes:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: $reading.notes)
                    .frame(height: 150)
                    .border(Color.gray, width: 1)

                Button("Save Changes") {
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save changes: \(error.localizedDescription)")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Back") {
                    dismiss()
                }
                .padding()
                .foregroundColor(.blue)
            }
            .padding()
        }
        .navigationTitle("Reading Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
