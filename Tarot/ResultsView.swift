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
    @Bindable var session: ReadingSession
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var notes: String = ""
    @State private var showAskSheet = false
    @State private var userQuestion = ""
    @State private var isAskingAI = false
    @State private var aiResponse: TarotAIResponse?
    @State private var aiError: String?

    private let aiClient = TarotAIClient()

    private var rows: [GridItem] {
        if session.selectedCards.count <= 4 {
            return [GridItem(.flexible())]
        } else if session.selectedCards.count <= 8 {
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
                        ForEach(Array(session.selectedCards.enumerated()), id: \.element.id) { index, card in
                            VStack(spacing: 8) {
                                CardView(card: card, isFaceUp: true)
                                    .aspectRatio(2 / 3, contentMode: .fit)
                                    .frame(width: cardWidth(for: geometry.size.width))

                                Text(positionLabel(for: index))
                                    .font(.caption.bold())
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                    .frame(width: cardWidth(for: geometry.size.width))
                            }
                        }
                    }
                    .padding(2)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: gridHeight())

                if !session.hexagramLines.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        

                        IChingPatternSummaryView(lines: session.hexagramLines)

                        Text(lineDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let selectedRune = session.selectedRune {
                    RuneSummaryView(rune: selectedRune)
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
                            session.reset()
                            navigationPath = NavigationPath()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)

                        Button("Save Reading") {
                            saveReading()
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }

                    HStack {
                        Button("Copy Card Names") {
                            UIPasteboard.general.string = cardNamesForClipboard()
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
                            if idx < session.selectedCards.count {
                                Text("• \(positionLabel(for: idx)) — \(session.selectedCards[idx].name): \(text)")
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
                        askAI()
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
            notes = addCardsToNotes()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func saveReading() {
        let trimmedQuestion = userQuestion.trimmingCharacters(in: .whitespacesAndNewlines)

        let reading = Reading(
            cardNames: session.selectedCards.map(\.name),
            notes: notes,
            rune: session.selectedRune,
            hexagramLines: session.hexagramLines,
            aiQuestion: trimmedQuestion.isEmpty ? nil : trimmedQuestion,
            aiResponseJSON: Reading.encodeAIResponseForSave(aiResponse)
        )

        modelContext.insert(reading)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save reading: \(error.localizedDescription)")
        }
    }

    private func askAI() {
        Task {
            isAskingAI = true
            aiError = nil

            do {
                let res = try await aiClient.interpret(
                    question: userQuestion,
                    selectedCards: session.selectedCards,
                    notes: notes,
                    rune: session.selectedRune,
                    hexagramLines: session.hexagramLines
                )

                aiResponse = res
                showAskSheet = false
            } catch {
                aiError = error.localizedDescription
            }

            isAskingAI = false
        }
    }

    private func cardWidth(for totalWidth: CGFloat) -> CGFloat {
        let columns = session.selectedCards.count <= 4 ? session.selectedCards.count : 4
        let spacing: CGFloat = 20 * CGFloat(max(columns - 1, 0))
        return max((totalWidth - spacing) / CGFloat(max(columns, 1)), 70)
    }

    private func gridHeight() -> CGFloat {
        let rowCount = session.selectedCards.count <= 4 ? 1 : session.selectedCards.count <= 8 ? 2 : 3
        let cardHeight = UIScreen.main.bounds.width / 4 * (3 / 2)

        return CGFloat(rowCount) * cardHeight + CGFloat((rowCount - 1) * 20) + 32
    }

    private func addCardsToNotes() -> String {
        session.selectedCards.enumerated()
            .map { index, card in
                "\(positionLabel(for: index)): \(card.name)"
            }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func cardNamesForClipboard() -> String {
        session.selectedCards.enumerated()
            .map { index, card in
                "\(positionLabel(for: index)): \(card.name)"
            }
            .joined(separator: "\n")
    }

    private func positionLabel(for index: Int) -> String {
        guard index < session.spreadPositions.count else {
            return "Card \(index + 1)"
        }

        let label = session.spreadPositions[index]
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return label.isEmpty ? "Card \(index + 1)" : label
    }

    private var lineDescription: String {
        guard !session.hexagramLines.isEmpty else { return "" }

        let changingLines = session.hexagramLines.filter { $0 == 6 || $0 == 9 }.count

        if changingLines == 0 {
            return "This pattern is stable."
        } else if changingLines == 1 {
            return "One line is changing."
        } else {
            return "\(changingLines) lines are changing."
        }
    }
}
