//
//  ResultsView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//
//
//  ResultsView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//
import SwiftUI
import UIKit // Make sure to import UIKit for UIPasteboard

struct ResultsView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedCards: [Card]
    @Environment(\.modelContext) private var modelContext
    @State private var notes: String = ""

    // Create dynamic rows based on the number of selected cards
    private var rows: [GridItem] {
        if selectedCards.count <= 4 {
            return [GridItem(.flexible())] // One row
        } else if selectedCards.count <= 8 {
            return [GridItem(.flexible()), GridItem(.flexible())] // Two rows
        } else {
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // Three rows
        }
    }

    var body: some View {
        VStack {
            Text("Your Reading")
                .font(.title)
                .padding(.bottom)

            GeometryReader { geometry in
                LazyHGrid(rows: rows, spacing: 20) {
                    ForEach(selectedCards) { card in
                        CardView(card: card, isFaceUp: true)
                            .aspectRatio(2 / 3, contentMode: .fit) // Maintain card aspect ratio
                            .frame(width: cardWidth(for: geometry.size.width)) // Dynamic width
                    }
                }
                .padding(2)
                .frame(maxWidth: .infinity) // Ensure the grid does not stretch rows
            }
            .frame(height: gridHeight()) // Constrain the height of the grid

            TextEditor(text: $notes)
                .frame(height: 100)
                .border(Color.gray)
                .padding(.vertical)
            
            HStack {
                Button("Back to Home") {
                    navigationPath = NavigationPath()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Save Reading") {
                    let reading = Reading(cardsChosen: selectedCards, notes: notes)
                    modelContext.insert(reading)
                    
                    do {
                        try modelContext.save()
                        print("Reading saved successfully: \(selectedCards.count), \(notes)")
                    } catch {
                        print("Failed to save reading: \(error.localizedDescription)")
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                // New Copy Button
                Button("Copy Card Names") {
                    let cardNames = selectedCards.map { $0.name }.joined(separator: "\n")
                    UIPasteboard.general.string = cardNames
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the entire view uses available space
        .padding()
        .onAppear() {
            notes = addCardsToNotes(cards: selectedCards)
        }
    }

    // Calculate dynamic card width
    private func cardWidth(for totalWidth: CGFloat) -> CGFloat {
        let columns = selectedCards.count <= 4 ? selectedCards.count : 4 // Max 4 cards per row
        let spacing: CGFloat = 20 * CGFloat(columns - 1) // Total spacing between cards
        return (totalWidth - spacing) / CGFloat(columns)
    }

    // Calculate grid height based on the number of rows and card height
    private func gridHeight() -> CGFloat {
        let rows = selectedCards.count <= 4 ? 1 : selectedCards.count <= 8 ? 2 : 3
        let cardHeight = UIScreen.main.bounds.width / 4 * (3 / 2) // 2:3 aspect ratio for cards
        return CGFloat(rows) * cardHeight + CGFloat((rows - 1) * 20) // Include spacing
    }
    
    private func addCardsToNotes(cards: [Card]) -> String {
        var updatedNotes = notes // Create a local variable to avoid modifying the state directly
        for card in cards {
            updatedNotes += card.name + "\n" // Append each card name with a newline
        }
        return updatedNotes.trimmingCharacters(in: .whitespaces) // Trim any trailing spaces
    }
}
