//
//  ResultsView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import SwiftUI
import UIKit

struct ResultsView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedCards: [Card]
    @Binding var selectedRune: String?
    @Binding var hexagramLines: [Int]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var notes: String = ""
    @State private var showAskSheet = false
    @State private var userQuestion = ""
    @State private var isAskingAI = false
    @State private var aiResponse: TarotAIResponse?
    @State private var aiError: String?

    private let aiClient = TarotAIClient()

    private var rows: [GridItem] {
        if selectedCards.count <= 4 {
            return [GridItem(.flexible())]
        } else if selectedCards.count <= 8 {
            return [GridItem(.flexible()), GridItem(.flexible())]
        } else {
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Reading")
                    .font(.title)
                    .padding(.bottom, 4)

                GeometryReader { geometry in
                    LazyHGrid(rows: rows, spacing: 20) {
                        ForEach(selectedCards) { card in
                            CardView(card: card, isFaceUp: true)
                                .aspectRatio(2 / 3, contentMode: .fit)
                                .frame(width: cardWidth(for: geometry.size.width))
                        }
                    }
                    .padding(2)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: gridHeight())

                if !hexagramLines.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pattern")
                            .font(.title2.bold())

                        HexagramDisplayView(lines: hexagramLines)

                        Text(lineDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let selectedRune {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rune")
                            .font(.title2.bold())

                        HStack(spacing: 12) {
                            Text(selectedRune)
                                .font(.system(size: 44))

                            Text(runeMeaning(for: selectedRune))
                                .font(.body)
                        }
                    }
                }

                Text("Notes")
                    .font(.headline)

                TextEditor(text: $notes)
                    .frame(height: 120)
                    .border(Color.gray)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button("Back to Home") {
                            selectedCards.removeAll()
                            selectedRune = nil
                            hexagramLines.removeAll()
                            navigationPath = NavigationPath()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)

                        Button("Save Reading") {
                            let reading = Reading(
                                cardNames: selectedCards.map(\.name),
                                notes: notes,
                                rune: selectedRune,
                                hexagramLines: hexagramLines
                            )
                            modelContext.insert(reading)

                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save reading: \(error.localizedDescription)")
                            }
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }

                    HStack {
                        Button("Copy Card Names") {
                            let cardNames = selectedCards.map { $0.name }.joined(separator: "\n")
                            UIPasteboard.general.string = cardNames
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)

                        Button("Ask ChatGPT") {
                            showAskSheet = true
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(10)
                    }
                }

                if let aiResponse {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI Interpretation")
                            .font(.title2.bold())

                        Text(aiResponse.summary)

                        Text("Card by card")
                            .font(.headline)

                        ForEach(Array(aiResponse.cardByCard.enumerated()), id: \.offset) { idx, text in
                            if idx < selectedCards.count {
                                Text("• \(selectedCards[idx].name): \(text)")
                            }
                        }

                        Text("Advice")
                            .font(.headline)

                        ForEach(aiResponse.advice, id: \.self) { item in
                            Text("• \(item)")
                        }

                        if !aiResponse.journalPrompts.isEmpty {
                            Text("Journal Prompts")
                                .font(.headline)

                            ForEach(aiResponse.journalPrompts, id: \.self) { prompt in
                                Text("• \(prompt)")
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showAskSheet) {
            NavigationView {
                VStack(spacing: 16) {
                    Text("What’s your question?")
                        .font(.headline)

                    TextEditor(text: $userQuestion)
                        .frame(height: 140)
                        .border(Color.gray.opacity(0.3))

                    if let aiError {
                        Text(aiError)
                            .foregroundColor(.red)
                    }

                    Button(isAskingAI ? "Asking..." : "Interpret") {
                        Task {
                            isAskingAI = true
                            aiError = nil

                            do {
                                let res = try await aiClient.interpret(
                                    question: userQuestion,
                                    selectedCards: selectedCards,
                                    notes: notes,
                                    rune: selectedRune,
                                    hexagramLines: hexagramLines
                                )
                                aiResponse = res
                                showAskSheet = false
                            } catch {
                                aiError = error.localizedDescription
                            }

                            isAskingAI = false
                        }
                    }
                    .disabled(isAskingAI || userQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(isAskingAI ? Color.gray : Color.purple)
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
                .navigationTitle("AI Reading")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAskSheet = false
                        }
                    }
                }
            }
        }
        .onAppear {
            notes = addCardsToNotes(cards: selectedCards)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func cardWidth(for totalWidth: CGFloat) -> CGFloat {
        let columns = selectedCards.count <= 4 ? selectedCards.count : 4
        let spacing: CGFloat = 20 * CGFloat(max(columns - 1, 0))
        return max((totalWidth - spacing) / CGFloat(max(columns, 1)), 70)
    }

    private func gridHeight() -> CGFloat {
        let rowCount = selectedCards.count <= 4 ? 1 : selectedCards.count <= 8 ? 2 : 3
        let cardHeight = UIScreen.main.bounds.width / 4 * (3 / 2)
        return CGFloat(rowCount) * cardHeight + CGFloat((rowCount - 1) * 20)
    }

    private func addCardsToNotes(cards: [Card]) -> String {
        cards.map(\.name).joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var lineDescription: String {
        guard !hexagramLines.isEmpty else { return "" }

        let changingLines = hexagramLines.filter { $0 == 6 || $0 == 9 }.count

        if changingLines == 0 {
            return "This pattern is stable."
        } else if changingLines == 1 {
            return "One line is changing."
        } else {
            return "\(changingLines) lines are changing."
        }
    }

    private func runeMeaning(for rune: String) -> String {
        switch rune {
        case "ᚠ":
            return "Wealth, flow, new movement"
        case "ᚢ":
            return "Strength, endurance, shaping force"
        case "ᚦ":
            return "Challenge, friction, breakthrough"
        case "ᚨ":
            return "Message, insight, clear expression"
        case "ᚱ":
            return "Journey, change, unfolding path"
        case "ᚲ":
            return "Flame, transformation, opening"
        case "ᚷ":
            return "Exchange, gift, mutual influence"
        case "ᚹ":
            return "Joy, harmony, wishes moving closer"
        case "ᚺ":
            return "Disruption, weather, uncontrolled force"
        case "ᚾ":
            return "Need, pressure, necessity"
        case "ᛁ":
            return "Stillness, focus, inner alignment"
        case "ᛃ":
            return "Harvest, cycles, reward in time"
        default:
            return "A symbol has appeared."
        }
    }
}

struct HexagramDisplayView: View {
    let lines: [Int]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(lines.enumerated()).reversed(), id: \.offset) { _, line in
                HStack(spacing: 10) {
                    if isYang(line) {
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: 170, height: 10)
                    } else {
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: 80, height: 10)

                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: 80, height: 10)
                    }

                    if isChanging(line) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: 170)
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }

    private func isYang(_ value: Int) -> Bool {
        value == 7 || value == 9
    }

    private func isChanging(_ value: Int) -> Bool {
        value == 6 || value == 9
    }
}
