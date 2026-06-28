//
//  CardMeaning.swift
//  Tarot
//
//  Created by Rosie on 3/7/26.
//


import SwiftUI

struct CardMeaning: View {
    let cardName: String
    
    @StateObject private var database = TarotDatabase()
    
    private var card: TarotCardMeaning? {
        database.cards.first { meaning in
            meaning.name == cardName
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if let card {
                    headerView(for: card)
                    
                    meaningSection(
                        title: "Core Essence",
                        text: card.coreEssence,
                        style: .featured
                    )
                    
                    VStack(spacing: 14) {
                        meaningSection(
                            title: "Light Expression",
                            text: card.lightExpression
                        )
                        
                        meaningSection(
                            title: "Shadow Expression",
                            text: card.shadowExpression
                        )
                    }
                    
                    meaningGroup(title: "Reading Themes") {
                        meaningSection(
                            title: "Love",
                            text: card.loveTheme,
                            isNested: true
                        )
                        
                        meaningSection(
                            title: "Career",
                            text: card.careerTheme,
                            isNested: true
                        )
                        
                        meaningSection(
                            title: "Spiritual",
                            text: card.spiritualTheme,
                            isNested: true
                        )
                    }
                    
                    meaningSection(
                        title: "Advice",
                        text: card.advice,
                        style: .featured
                    )
                    
                    meaningGroup(title: "Symbolic Details") {
                        detailRow(title: "Emotional Tone", value: card.emotionalTone)
                        detailRow(title: "Elemental Energy", value: card.elementalEnergy)
                        detailRow(title: "Archetype Role", value: card.archetypeRole)
                    }
                    
                    meaningSection(
                        title: "Keywords",
                        text: card.keywords.joined(separator: " • ")
                    )
                } else {
                    missingCardView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .background(appBackground)
        .navigationTitle(card?.name ?? cardName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Main Views

private extension CardMeaning {
    func headerView(for card: TarotCardMeaning) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(card.name)
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
            
            ZStack {
                Image(card.name)
                    .resizable()
                    .frame(width: 170, height: 170 * (1810.0 / 1086.0))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                ShinyViewWrapper()
                    .frame(width: 170, height: 170 * (1810.0 / 1086.0))
                    .opacity(0.4)
                    .blendMode(.screen)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            
            if let suit = card.suit {
                Text(suit)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.top, 6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
        )
    }
    
    func meaningGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }
    
    func meaningSection(
        title: String,
        text: String,
        style: MeaningSectionStyle = .standard,
        isNested: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(isNested ? .subheadline.bold() : .headline)
                .foregroundStyle(.primary)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(isNested ? 0 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if !isNested {
                switch style {
                case .standard:
                    cardBackground
                case .featured:
                    featuredBackground
                }
            }
        }
    }
    
    func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var missingCardView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(cardName)
                .font(.largeTitle.bold())
            
            Text("No meaning was found for this card.")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Check that the card name passed into this view matches the name or id in tarot_meanings_full_78.json.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }
}

// MARK: - Styling

private extension CardMeaning {
    var appBackground: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.purple.opacity(0.10),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            )
    }
    
    var featuredBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.18),
                        Color.indigo.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.purple.opacity(0.20), lineWidth: 1)
            )
    }
}

private enum MeaningSectionStyle {
    case standard
    case featured
}

// MARK: - Matching Helper

private extension String {
    var normalizedCardName: String {
        self
            .lowercased()
            .replacingOccurrences(of: "the ", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
