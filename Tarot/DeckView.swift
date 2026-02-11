//
//  DeckView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI

struct DeckView1: View {
    @Binding var navigationPath: NavigationPath
    @State private var deck: [Card] = []
    @Binding var selectedCards: [Card]
    let spreadCount: Int
    
    // This controls how many cards are currently visible
    @State private var visibleCardCount: Int = 0
    
    func shuffleDeck(cards: [Card]) -> [Card] {
        return cards.shuffled()
    }

    func createDeck() -> [Card] {
        let names = [
            "The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
            "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
            "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
            "The Devil", "The Tower", "The Star", "The Moon", "The Sun",
            "Judgement", "The World", "Ace of Wands", "Two of Wands", "Three of Wands",
            "Four of Wands", "Five of Wands", "Six of Wands", "Seven of Wands", "Eight of Wands",
            "Nine of Wands", "Ten of Wands", "Page of Wands", "Knight of Wands", "Queen of Wands",
            "King of Wands", "Ace of Cups", "Two of Cups", "Three of Cups", "Four of Cups",
            "Five of Cups", "Six of Cups", "Seven of Cups", "Eight of Cups", "Nine of Cups",
            "Ten of Cups", "Page of Cups", "Knight of Cups", "Queen of Cups", "King of Cups",
            "Ace of Swords", "Two of Swords", "Three of Swords", "Four of Swords", "Five of Swords",
            "Six of Swords", "Seven of Swords", "Eight of Swords", "Nine of Swords", "Ten of Swords",
            "Page of Swords", "Knight of Swords", "Queen of Swords", "King of Swords",
            "Ace of Pentacles", "Two of Pentacles", "Three of Pentacles", "Four of Pentacles",
            "Five of Pentacles", "Six of Pentacles", "Seven of Pentacles", "Eight of Pentacles",
            "Nine of Pentacles", "Ten of Pentacles", "Page of Pentacles", "Knight of Pentacles",
            "Queen of Pentacles", "King of Pentacles"
        ]

        return names.map { Card(name: $0) }
    }

    func selectCard(_ card: Card) {
        if selectedCards.count < spreadCount, !selectedCards.contains(where: { $0.id == card.id }) {
            selectedCards.append(card)
            if selectedCards.count == spreadCount {
                navigationPath.append("ResultsView")
            }
        }
    }

    var body: some View {
        VStack {
            Text("Choose Your Cards")
                .font(.title)
                .padding()

            ScrollView {
                VStack(spacing: -10) {
                    ForEach(deck.chunked(into: 26).enumerated().map({ $0 }), id: \.offset) { rowIndex, row in
                        HStack(spacing: -68) {
                            ForEach(Array(row.enumerated()), id: \.element.id) { cardIndex, card in
                                // Determine the index of the card overall
                                let overallIndex = rowIndex * 26 + cardIndex
                                
                                // Only show the card if it's within the visible count
                                if overallIndex < visibleCardCount {
                                    CardView(card: card,
                                             isFaceUp: selectedCards.contains(where: { $0.id == card.id }))
                                    .transition(.push(from: .top))
                                        .onTapGesture {
                                            selectCard(card)
                                        }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            deck = createDeck()
            deck = shuffleDeck(cards: deck)
            selectedCards = []
            
            // Animate the reveal of cards one by one
            revealCardsStaggered()
        }
        .onDisappear {
            deck = []
            visibleCardCount = 0
        }
    }
    
    func revealCardsStaggered() {
        for i in 0..<deck.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.02)) { // 0.05s delay per card
                withAnimation(.smooth(duration: 0.2)) {
                    visibleCardCount = i + 1
                }
            }
        }
    }
}

