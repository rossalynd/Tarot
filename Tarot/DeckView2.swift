//
//  DeckView2.swift
//  Tarot
//
//  Created by Rosie on 12/14/25.
//

import Foundation
import SwiftUI

struct DeckView: View {
    @Binding var navigationPath: NavigationPath
    @State private var deck: [Card] = []
    @Binding var selectedCards: [Card]
    let spreadCount: Int
    
    @State private var visibleCardCount: Int = 0
    @State private var activeParticles: [(id: UUID, position: CGPoint)] = []
    @State private var animatingCards: Set<UUID> = []
    @State private var animatingCardPosition: CGPoint?
    
    func shuffleDeck(cards: [Card]) -> [Card] {
        cards.shuffled()
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
    
    func selectCard(_ card: Card, at position: CGPoint) {
        if selectedCards.count < spreadCount, !selectedCards.contains(where: { $0.id == card.id }) {
            animatingCards.insert(card.id)
            animatingCardPosition = position
            activeParticles.append((id: card.id, position: position))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    selectedCards.append(card)
                    animatingCardPosition = nil
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                animatingCards.remove(card.id)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                activeParticles.removeAll { $0.id == card.id }
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Choose Your Cards")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                VStack(spacing: -20) {
                    ForEach(deck.chunked(into: 26).enumerated().map({ $0 }), id: \.offset) { rowIndex, row in
                        HStack(spacing: -58) {
                            ForEach(Array(row.enumerated()), id: \.element.id) { cardIndex, card in
                                let overallIndex = rowIndex * 26 + cardIndex
                                let isSelected = selectedCards.contains(where: { $0.id == card.id })
                                let isAnimating = animatingCards.contains(card.id)
                                
                                if overallIndex < visibleCardCount {
                                    if isSelected && !isAnimating {
                                        Color.clear
                                            .frame(width: 70, height: 120)
                                    } else if isAnimating {
                                        Color.clear
                                            .frame(width: 70, height: 120)
                                    } else {
                                        GeometryReader { geo in
                                            CardView(card: card, isFaceUp: false)
                                                .onTapGesture {
                                                    let frame = geo.frame(in: .named("deckView"))
                                                    let position = CGPoint(
                                                        x: frame.midX,
                                                        y: frame.midY
                                                    )
                                                    selectCard(card, at: position)
                                                }
                                        }
                                        .frame(width: 70, height: 120)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                    }
                }
                .padding()
                .padding(.bottom, selectedCards.isEmpty ? 0 : 180)
                
                Spacer()
            }
            
            if let animatingCard = deck.first(where: { animatingCards.contains($0.id) }),
               animatingCardPosition != nil {
                GeometryReader { geo in
                    let screenCenter = CGPoint(
                        x: geo.size.width / 2,
                        y: geo.size.height / 2
                    )
                    
                    CardView(card: animatingCard, isFaceUp: true)
                        .frame(width: 70, height: 120)
                        .scaleEffect(3.5)
                        .position(screenCenter)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(2000)
                }
            }
            
            if !selectedCards.isEmpty {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Selected Cards (\(selectedCards.count)/\(spreadCount))")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            ZStack {
                                Spacer().containerRelativeFrame(.horizontal)
                                
                                HStack(spacing: 15) {
                                    ForEach(selectedCards) { card in
                                        CardView(card: card, isFaceUp: true)
                                            .frame(width: 60, height: 100)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(height: 120)
                        
                        if selectedCards.count == spreadCount {
                            Button(action: {
                                navigationPath.append("IChingSelectionView")
                            }) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding()
                    .shadow(radius: 5)
                }
            }
            
            ForEach(activeParticles, id: \.id) { particle in
                ParticleEffectView(startPosition: particle.position)
            }
        }
        .coordinateSpace(name: "deckView")
        .onAppear {
            deck = createDeck()
            deck = shuffleDeck(cards: deck)
            selectedCards = []
            revealCardsStaggered()
        }
        .onDisappear {
            deck = []
            visibleCardCount = 0
        }
    }
    
    func revealCardsStaggered() {
        for i in 0..<deck.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.02)) {
                withAnimation(.smooth(duration: 0.2)) {
                    visibleCardCount = i + 1
                }
            }
        }
    }
}
