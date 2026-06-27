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
    @State private var originalNotes: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tarot")
                    .font(.title2.bold())

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
                    IChingPatternSummaryView(lines: reading.hexagramLines)
                }

                if let rune = reading.rune {
                    RuneSummaryView(rune: rune)
                }

                Text("Notes:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextEditor(text: $reading.notes)
                    .frame(height: 150)
                    .border(Color.gray, width: 1)
                    .onAppear {
                        originalNotes = reading.notes
                    }
                
                if let aiQuestion = reading.aiQuestion {
                    Text("Question")
                        .font(.headline)

                    Text(aiQuestion)
                }

                if let savedAIResponse = reading.savedAIResponse {
                    Text("AI Interpretation")
                        .font(.title2.bold())

                    Text(savedAIResponse.summary)

                    Text("Card by card")
                        .font(.headline)

                    ForEach(savedAIResponse.cardByCard, id: \.self) { item in
                        Text("• \(item)")
                    }

                    Text("Advice")
                        .font(.headline)

                    ForEach(savedAIResponse.advice, id: \.self) { item in
                        Text("• \(item)")
                    }

                    if !savedAIResponse.journalPrompts.isEmpty {
                        Text("Journal Prompts")
                            .font(.headline)

                        ForEach(savedAIResponse.journalPrompts, id: \.self) { prompt in
                            Text("• \(prompt)")
                        }
                    }
                }

                Button("Save") {
                    do {
                        try modelContext.save()
                        originalNotes = reading.notes
                    } catch {
                        print("Failed to save changes: \(error.localizedDescription)")
                    }
                }
                .disabled(reading.notes == originalNotes)
                .opacity(reading.notes == originalNotes ? 0.5 : 1)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                
            }
            .padding()
        }
        .navigationTitle("Reading Details")
        .navigationBarTitleDisplayMode(.inline)
    }

   
}
