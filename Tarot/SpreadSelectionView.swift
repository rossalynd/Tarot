//
//  SpreadSelectionView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI

struct TarotSpread: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let cardCount: Int
    let description: String
    let positions: [String]
    let isCustom: Bool

    init(
        name: String,
        cardCount: Int,
        description: String,
        positions: [String],
        isCustom: Bool = false
    ) {
        self.name = name
        self.cardCount = cardCount
        self.description = description
        self.positions = positions
        self.isCustom = isCustom
    }
}

struct SpreadSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Bindable var session: ReadingSession

    @State private var selectedSpread: TarotSpread = TarotSpread.allSpreads[0]
    @State private var customCardCount: Int = 3
    @State private var customLabels: [String] = [
        "Card 1",
        "Card 2",
        "Card 3"
    ]

    private var activeCardCount: Int {
        selectedSpread.isCustom ? customCardCount : selectedSpread.cardCount
    }

    private var activePositions: [String] {
        selectedSpread.isCustom ? cleanedCustomLabels : selectedSpread.positions
    }

    private var cleanedCustomLabels: [String] {
        customLabels.enumerated().map { index, label in
            let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedLabel.isEmpty ? "Card \(index + 1)" : trimmedLabel
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Spread")
                .font(.largeTitle.bold())

            Text("Select the kind of reading you want.")
                .font(.headline)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(TarotSpread.allSpreads) { spread in
                        SpreadOptionCard(
                            spread: spread,
                            cardCount: displayCardCount(for: spread),
                            positions: displayPositions(for: spread),
                            isSelected: selectedSpread == spread
                        ) {
                            selectedSpread = spread
                        }
                    }

                    if selectedSpread.isCustom {
                        CustomSpreadEditor(
                            customCardCount: $customCardCount,
                            customLabels: $customLabels
                        )
                    }
                }
                .padding(.horizontal)
            }

            Button {
                session.spreadPositions = activePositions
                session.selectedCards.removeAll()
                session.selectedRune = nil
                session.hexagramLines.removeAll()

                navigationPath.append("DeckView")
            } label: {
                Text("Choose \(activeCardCount) Card\(activeCardCount == 1 ? "" : "s")")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") {
                    navigationPath.removeLast()
                }
            }
        }
        
    }

    private func displayCardCount(for spread: TarotSpread) -> Int {
        spread.isCustom ? customCardCount : spread.cardCount
    }

    private func displayPositions(for spread: TarotSpread) -> [String] {
        spread.isCustom ? cleanedCustomLabels : spread.positions
    }
}

private struct SpreadOptionCard: View {
    let spread: TarotSpread
    let cardCount: Int
    let positions: [String]
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spread.name)
                            .font(.headline)

                        Text("\(cardCount) card\(cardCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.blue : Color.secondary)
                }

                Text(spread.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                if !positions.isEmpty {
                    Text(positions.joined(separator: " • "))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.12) : Color.gray.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct CustomSpreadEditor: View {
    @Binding var customCardCount: Int
    @Binding var customLabels: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Spread")
                .font(.headline)

            Picker("Number of Cards", selection: $customCardCount) {
                ForEach(1...12, id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: customCardCount) { _, newValue in
                updateLabels(for: newValue)
            }

            VStack(spacing: 10) {
                ForEach(customLabels.indices, id: \.self) { index in
                    TextField(
                        "Card \(index + 1)",
                        text: bindingForLabel(at: index)
                    )
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.10))
        )
    }

    private func bindingForLabel(at index: Int) -> Binding<String> {
        Binding(
            get: {
                customLabels[index]
            },
            set: { newValue in
                customLabels[index] = newValue
            }
        )
    }

    private func updateLabels(for count: Int) {
        if customLabels.count < count {
            let newLabels = (customLabels.count + 1...count).map { "Card \($0)" }
            customLabels.append(contentsOf: newLabels)
        } else if customLabels.count > count {
            customLabels = Array(customLabels.prefix(count))
        }
    }
}


extension TarotSpread {
    static let allSpreads: [TarotSpread] = [
        TarotSpread(
            name: "One-Card Pull",
            cardCount: 1,
            description: "A quick reading for daily guidance, reflection, or a simple question.",
            positions: [
                "Message"
            ]
        ),

        TarotSpread(
            name: "Three-Card Spread",
            cardCount: 3,
            description: "A classic spread for simple but nuanced insight.",
            positions: [
                "Past",
                "Present",
                "Future"
            ]
        ),

        TarotSpread(
            name: "Situation, Obstacle, Advice",
            cardCount: 3,
            description: "A practical spread for understanding what is happening and what to do next.",
            positions: [
                "Situation",
                "Obstacle",
                "Advice"
            ]
        ),

        TarotSpread(
            name: "Relationship Spread",
            cardCount: 6,
            description: "A spread for romance, friendship, family, or any important connection.",
            positions: [
                "Your Energy",
                "Their Energy",
                "Connection",
                "What Helps",
                "What Hurts",
                "Likely Direction"
            ]
        ),

        TarotSpread(
            name: "Decision / Two-Path Spread",
            cardCount: 6,
            description: "A crossroads spread for comparing two possible choices.",
            positions: [
                "Current Situation",
                "Path A",
                "Outcome of Path A",
                "Path B",
                "Outcome of Path B",
                "Advice"
            ]
        ),

        TarotSpread(
            name: "Shadow Work Spread",
            cardCount: 4,
            description: "A deeper spread for hidden feelings, avoidance, and inner integration.",
            positions: [
                "What You Are Avoiding",
                "Why",
                "Lesson",
                "Integration"
            ]
        ),

        TarotSpread(
            name: "New Moon Spread",
            cardCount: 4,
            description: "A spread for intention-setting, beginnings, and quiet renewal.",
            positions: [
                "What You Are Planting",
                "Intention",
                "Support Needed",
                "First Step"
            ]
        ),

        TarotSpread(
            name: "Full Moon Spread",
            cardCount: 4,
            description: "A spread for clarity, release, culmination, and reflection.",
            positions: [
                "What Has Come to Light",
                "What to Release",
                "What to Celebrate",
                "What Comes Next"
            ]
        ),

        TarotSpread(
            name: "What Do I Need to Know?",
            cardCount: 5,
            description: "A flexible spread for open-ended questions and unseen influences.",
            positions: [
                "Situation",
                "What You See",
                "What You Do Not See",
                "Advice",
                "Likely Outcome"
            ]
        ),

        TarotSpread(
            name: "Celtic Cross",
            cardCount: 10,
            description: "A detailed traditional spread for complex or labyrinthine situations.",
            positions: [
                "Present",
                "Challenge",
                "Root Cause",
                "Recent Past",
                "Conscious Focus",
                "Near Future",
                "Your Role",
                "Outside Influences",
                "Hopes and Fears",
                "Outcome"
            ]
        ),

        TarotSpread(
            name: "Year Ahead Spread",
            cardCount: 12,
            description: "A broad seasonal reading with one card for each month of the year.",
            positions: [
                "January",
                "February",
                "March",
                "April",
                "May",
                "June",
                "July",
                "August",
                "September",
                "October",
                "November",
                "December"
            ]
        ),

        TarotSpread(
            name: "Custom Spread",
            cardCount: 3,
            description: "Create your own spread and label each card position.",
            positions: [
                "Card 1",
                "Card 2",
                "Card 3"
            ],
            isCustom: true
        )
    ]
}
