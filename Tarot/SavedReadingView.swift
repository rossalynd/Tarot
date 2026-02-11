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
    @Bindable var reading: Reading // SwiftData model as Bindable
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            // Display cards horizontally
            ScrollView(.horizontal) {
                HStack {
                    ForEach(reading.cardsChosen, id: \.id) { card in
                        CardView(card: card, isFaceUp: true)
                    }
                }
            }
            .padding(5)

            // Editable Notes Section
            Text("Notes:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)

            TextEditor(text: $reading.notes)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding()

            // Save Button
            Button("Save Changes") {
                do {
                    try modelContext.save()
                    print("Notes updated successfully")
                } catch {
                    print("Failed to save changes: \(error.localizedDescription)")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()

            // Back Button
            Button("Back") {
                dismiss()
            }
            .padding()
            .foregroundColor(.blue)
        }
        .padding()
        .navigationTitle("Reading Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
