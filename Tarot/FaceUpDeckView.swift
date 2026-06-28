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
    @State private var collapsedSections: Set<String> = [
        "Major Arcana",
        "Wands",
        "Cups",
        "Swords",
        "Pentacles"
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 96), spacing: 18)
    ]

    private var groupedDeck: [SuitSection] {
        [
            SuitSection(
                title: "Major Arcana",
                subtitle: "The soul’s larger journey",
                cards: deck.filter { cardSuit(for: $0.name) == .majorArcana }
            ),
            SuitSection(
                title: "Wands",
                subtitle: "Action, passion, and creative fire",
                cards: deck.filter { cardSuit(for: $0.name) == .wands }
            ),
            SuitSection(
                title: "Cups",
                subtitle: "Emotion, intuition, and relationships",
                cards: deck.filter { cardSuit(for: $0.name) == .cups }
            ),
            SuitSection(
                title: "Swords",
                subtitle: "Thought, truth, and clarity",
                cards: deck.filter { cardSuit(for: $0.name) == .swords }
            ),
            SuitSection(
                title: "Pentacles",
                subtitle: "Body, work, and the material world",
                cards: deck.filter { cardSuit(for: $0.name) == .pentacles }
            )
        ]
    }

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    ForEach(groupedDeck) { section in
                        if !section.cards.isEmpty {
                            suitSection(section)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            deck = createDeck()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.purple.opacity(0.10),
                Color.indigo.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose a Card")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("Browse the deck by suit and select a card to view its meaning.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 6)
    }

    private func suitSection(_ section: SuitSection) -> some View {
        let isCollapsed = collapsedSections.contains(section.id)

        return VStack(alignment: .leading, spacing: isCollapsed ? 0 : 16) {
            sectionHeader(section, isCollapsed: isCollapsed)

            if !isCollapsed {
                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(section.cards) { card in
                        cardTile(card)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 8)
        }
        .clipped()
        .animation(.easeInOut(duration: 0.22), value: isCollapsed)
    }

    private func sectionHeader(_ section: SuitSection, isCollapsed: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                toggleSection(section.id)
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    Text(section.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()


                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func cardTile(_ card: Card) -> some View {
        Button {
            navigationPath.append(CardMeaningRoute(cardName: card.name))
        } label: {
            VStack(spacing: 10) {
                CardView(card: card, isFaceUp: true)
                    .frame(width: 92, height: 154)
                    .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 5)

                Text(card.name)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .frame(width: 96, height: 32, alignment: .top)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func toggleSection(_ id: String) {
        if collapsedSections.contains(id) {
            collapsedSections.remove(id)
        } else {
            collapsedSections.insert(id)
        }
    }

    private func cardSuit(for name: String) -> TarotSuit {
        if name.contains("Wands") {
            return .wands
        } else if name.contains("Cups") {
            return .cups
        } else if name.contains("Swords") {
            return .swords
        } else if name.contains("Pentacles") {
            return .pentacles
        } else {
            return .majorArcana
        }
    }

    private func createDeck() -> [Card] {
        let names = [
            "The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
            "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
            "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
            "The Devil", "The Tower", "The Star", "The Moon", "The Sun",
            "Judgement", "The World",

            "Ace of Wands", "Two of Wands", "Three of Wands", "Four of Wands",
            "Five of Wands", "Six of Wands", "Seven of Wands", "Eight of Wands",
            "Nine of Wands", "Ten of Wands", "Page of Wands", "Knight of Wands",
            "Queen of Wands", "King of Wands",

            "Ace of Cups", "Two of Cups", "Three of Cups", "Four of Cups",
            "Five of Cups", "Six of Cups", "Seven of Cups", "Eight of Cups",
            "Nine of Cups", "Ten of Cups", "Page of Cups", "Knight of Cups",
            "Queen of Cups", "King of Cups",

            "Ace of Swords", "Two of Swords", "Three of Swords", "Four of Swords",
            "Five of Swords", "Six of Swords", "Seven of Swords", "Eight of Swords",
            "Nine of Swords", "Ten of Swords", "Page of Swords", "Knight of Swords",
            "Queen of Swords", "King of Swords",

            "Ace of Pentacles", "Two of Pentacles", "Three of Pentacles",
            "Four of Pentacles", "Five of Pentacles", "Six of Pentacles",
            "Seven of Pentacles", "Eight of Pentacles", "Nine of Pentacles",
            "Ten of Pentacles", "Page of Pentacles", "Knight of Pentacles",
            "Queen of Pentacles", "King of Pentacles"
        ]

        return names.map { Card(name: $0) }
    }
}

private enum TarotSuit {
    case majorArcana
    case wands
    case cups
    case swords
    case pentacles
}

private struct SuitSection: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let cards: [Card]

    init(title: String, subtitle: String, cards: [Card]) {
        self.id = title
        self.title = title
        self.subtitle = subtitle
        self.cards = cards
    }
}
