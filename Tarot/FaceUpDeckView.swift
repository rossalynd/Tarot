//
//  FaceUpDeckView.swift
//  Tarot
//
//  Created by Rosie on 3/7/26.
//


import SwiftUI

struct FaceUpDeckView: View {
    @Binding var navigationPath: NavigationPath
    
    @State private var deck: [Card] = []
    
    private let columns = [
        GridItem(.adaptive(minimum: 90), spacing: 16)
    ]
    
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Choose a Card")
                    .font(.largeTitle.bold())
                    .padding(.top)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(deck) { card in
                        VStack(spacing: 8) {
                            CardView(card: card, isFaceUp: true)
                                .frame(width: 90, height: 150)
                                .contentShape(Rectangle())
                            
                            Text(card.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .frame(width: 90)
                        }
                        .onTapGesture {
                            navigationPath.append(CardMeaningRoute(cardName: card.name))
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            deck = createDeck()
        }
    }
}