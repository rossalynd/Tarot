//
//  DeckView2.swift
//  Tarot
//
//  Created by Rosie on 12/14/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct DeckView: View {
    @Binding var navigationPath: NavigationPath
    @Bindable var session: ReadingSession

    @State private var cardRevealPlayer: AVAudioPlayer?
    @State private var cardSelectPlayer: AVAudioPlayer?

    @State private var deck: [Card] = []
    @State private var visibleCardCount: Int = 0

    @State private var activeParticles: [(id: UUID, position: CGPoint)] = []
    @State private var animatingCards: Set<UUID> = []

    @State private var flyingCard: FlyingCard?
    @State private var flightPhase: CardFlightPhase = .start

    private let deckCardSize = CGSize(width: 70, height: 120)
    private let selectedCardSize = CGSize(width: 60, height: 100)

    private let trayHeight: CGFloat = 220
    private let trayBottomPadding: CGFloat = 16

    private enum CardFlightPhase {
        case start
        case center
        case tray
    }

    private struct FlyingCard: Identifiable {
        let id: UUID
        let card: Card
        let startPosition: CGPoint
        let targetIndex: Int
    }

    var body: some View {
        GeometryReader { outerGeo in
            ZStack {
                fixedLayout(in: outerGeo.size)
                    .zIndex(0)

                if let flyingCard {
                    flyingCardView(
                        flyingCard,
                        in: outerGeo.size
                    )
                    .zIndex(3000)
                }

                ForEach(activeParticles, id: \.id) { particle in
                    ParticleEffectView(startPosition: particle.position)
                        .zIndex(4000)
                }
            }
            .frame(
                width: outerGeo.size.width,
                height: outerGeo.size.height
            )
            .coordinateSpace(name: "deckView")
        }
        .onAppear {
            deck = shuffleDeck(cards: createDeck())
            session.selectedCards = []
            revealCardsStaggered()
        }
        .onDisappear {
            deck = []
            visibleCardCount = 0
            flyingCard = nil
            animatingCards.removeAll()
            activeParticles.removeAll()
            flightPhase = .start
        }
    }

    private func fixedLayout(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            mainDeckView
                .frame(
                    width: size.width,
                    height: max(size.height - trayHeight, 0),
                    alignment: .top
                )

            selectedCardsTray
                .frame(
                    width: size.width,
                    height: trayHeight,
                    alignment: .bottom
                )
        }
        .frame(
            width: size.width,
            height: size.height,
            alignment: .top
        )
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private var mainDeckView: some View {
        VStack(spacing: -20) {
            Text("Choose Your Cards")
                .font(.title)
                .padding(.bottom, 20)

            ForEach(deck.chunked(into: 26).enumerated().map { $0 }, id: \.offset) { rowIndex, row in
                HStack(spacing: -58) {
                    ForEach(Array(row.enumerated()), id: \.element.id) { cardIndex, card in
                        deckCardSlot(
                            card: card,
                            overallIndex: rowIndex * 26 + cardIndex
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func deckCardSlot(
        card: Card,
        overallIndex: Int
    ) -> some View {
        let isVisible = overallIndex < visibleCardCount
        let isSelected = session.selectedCards.contains { $0.id == card.id }
        let isAnimating = animatingCards.contains(card.id)

        let shouldShowCard = isVisible && !isSelected && !isAnimating
        let canTapCard =
            shouldShowCard &&
            session.selectedCards.count < session.spreadCount &&
            flyingCard == nil

        return GeometryReader { geo in
            CardView(card: card, isFaceUp: false)
                .opacity(shouldShowCard ? 1 : 0)
                .scaleEffect(shouldShowCard ? 1 : 0.92)
                .offset(y: shouldShowCard ? 0 : 8)
                .blur(radius: shouldShowCard ? 0 : 2)
                .allowsHitTesting(canTapCard)
                .contentShape(Rectangle())
                .animation(
                    .smooth(duration: 0.25),
                    value: visibleCardCount
                )
                .onTapGesture {
                    guard canTapCard else { return }

                    let frame = geo.frame(in: .named("deckView"))

                    let position = CGPoint(
                        x: frame.midX,
                        y: frame.midY
                    )

                    selectCard(card, at: position)
                }
        }
        .frame(
            width: deckCardSize.width,
            height: deckCardSize.height
        )
    }

    private var selectedCardsTray: some View {
        VStack(spacing: 8) {
            Text("Selected Cards (\(session.selectedCards.count)/\(session.spreadCount))")
                .font(.headline)
                .padding(.top, 8)

            selectedCardsRow
                .frame(height: 120)
                .padding(.horizontal, 40)

            continueButton
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, trayBottomPadding)
        .shadow(radius: 5)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private var selectedCardsRow: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            ZStack {
                Spacer()
                    .containerRelativeFrame(.horizontal)

                HStack {
                    ForEach(session.selectedCards) { card in
                        CardView(card: card, isFaceUp: true)
                            .frame(
                                width: selectedCardSize.width,
                                height: selectedCardSize.height
                            )
                            .padding(.trailing, 10)
                    }
                }
            }
        }
    }

    private var continueButton: some View {
        Button {
            navigationPath.append("IChingSelectionView")
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    session.selectedCards.count == session.spreadCount
                    ? Color.blue
                    : Color.gray.opacity(0.4)
                )
                .cornerRadius(10)
        }
        .disabled(session.selectedCards.count != session.spreadCount)
        .opacity(session.selectedCards.count == session.spreadCount ? 1 : 0.35)
    }

    private func flyingCardView(
        _ flyingCard: FlyingCard,
        in containerSize: CGSize
    ) -> some View {
        let centerPosition = CGPoint(
            x: containerSize.width / 2,
            y: containerSize.height * 0.42
        )

        let trayPosition = selectedCardLandingPosition(
            targetIndex: flyingCard.targetIndex,
            containerSize: containerSize
        )

        let position: CGPoint = {
            switch flightPhase {
            case .start:
                return flyingCard.startPosition
            case .center:
                return centerPosition
            case .tray:
                return trayPosition
            }
        }()

        let scale: CGFloat = {
            switch flightPhase {
            case .start:
                return 1.0
            case .center:
                return 2.8
            case .tray:
                return selectedCardSize.width / deckCardSize.width
            }
        }()

        let opacity: Double = {
            switch flightPhase {
            case .start:
                return 1.0
            case .center:
                return 1.0
            case .tray:
                return 0.1
            }
        }()

        return CardView(card: flyingCard.card, isFaceUp: true)
            .frame(
                width: deckCardSize.width,
                height: deckCardSize.height
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .shadow(radius: flightPhase == .center ? 20 : 5)
            .allowsHitTesting(false)
    }

    private func selectedCardLandingPosition(
        targetIndex: Int,
        containerSize: CGSize
    ) -> CGPoint {
        let cardWidth = selectedCardSize.width
        let spacing: CGFloat = 15
        let horizontalPadding: CGFloat = 24

        let totalCount = session.selectedCards.count + 1

        let totalWidth =
            CGFloat(totalCount) * cardWidth +
            CGFloat(max(totalCount - 1, 0)) * spacing

        let leadingX = (containerSize.width - totalWidth) / 2

        let rawX =
            leadingX +
            CGFloat(targetIndex) * (cardWidth + spacing) +
            cardWidth / 2

        let clampedX = min(
            max(rawX, cardWidth / 2 + horizontalPadding),
            containerSize.width - cardWidth / 2 - horizontalPadding
        )

        let trayTopY = containerSize.height - trayHeight
        let selectedCardRowCenterY = trayTopY + 85

        return CGPoint(
            x: clampedX,
            y: selectedCardRowCenterY
        )
    }

    private func selectCard(_ card: Card, at position: CGPoint) {
        guard session.selectedCards.count < session.spreadCount else { return }
        guard !session.selectedCards.contains(where: { $0.id == card.id }) else { return }
        guard flyingCard == nil else { return }

        playSound(named: "cardSelect")

        animatingCards.insert(card.id)
        activeParticles.append((id: card.id, position: position))

        flyingCard = FlyingCard(
            id: card.id,
            card: card,
            startPosition: position,
            targetIndex: session.selectedCards.count
        )

        flightPhase = .start

        withAnimation(.smooth(duration: 0.45)) {
            flightPhase = .center
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.smooth(duration: 0.55)) {
                flightPhase = .tray
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
            var transaction = Transaction()
            transaction.disablesAnimations = true

            withTransaction(transaction) {
                session.selectedCards.append(card)
                flyingCard = nil
                animatingCards.remove(card.id)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            activeParticles.removeAll { $0.id == card.id }
        }
    }

    private func revealCardsStaggered() {
        playSound(named: "cardReveal")

        for i in 0..<deck.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                withAnimation(.smooth(duration: 0.2)) {
                    visibleCardCount = i + 1
                }
            }
        }
    }

    private func shuffleDeck(cards: [Card]) -> [Card] {
        cards.shuffled()
    }

    private func createDeck() -> [Card] {
        let names = [
            "The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
            "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
            "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
            "The Devil", "The Tower", "The Star", "The Moon", "The Sun",
            "Judgement", "The World",

            "Ace of Wands", "Two of Wands", "Three of Wands", "Four of Wands", "Five of Wands",
            "Six of Wands", "Seven of Wands", "Eight of Wands", "Nine of Wands", "Ten of Wands",
            "Page of Wands", "Knight of Wands", "Queen of Wands", "King of Wands",

            "Ace of Cups", "Two of Cups", "Three of Cups", "Four of Cups", "Five of Cups",
            "Six of Cups", "Seven of Cups", "Eight of Cups", "Nine of Cups", "Ten of Cups",
            "Page of Cups", "Knight of Cups", "Queen of Cups", "King of Cups",

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

    private func playSound(named name: String, extension fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("Sound file not found: \(name).\(fileExtension)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()

            if name == "cardReveal" {
                cardRevealPlayer = player
            } else if name == "cardSelect" {
                cardSelectPlayer = player
            }
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}
