//
//  SavedReadingView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import SwiftUI
import SwiftData

struct SavedReadingView: View {
    @Bindable var reading: Reading

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var originalNotes: String = ""

    private var hasUnsavedNotes: Bool {
        reading.notes != originalNotes
    }

    private var cardGridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]
    }

    var body: some View {
        ZStack {
            readingBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection

                    if !reading.cardNames.isEmpty {
                        tarotSection
                    }

                    if !reading.hexagramLines.isEmpty {
                        ReadingDetailSection(title: "I Ching") {
                            IChingPatternSummaryView(lines: reading.hexagramLines)
                        }
                    }

                    if let rune = reading.rune {
                        ReadingDetailSection(title: "Rune") {
                            RuneSummaryView(rune: rune)
                        }
                    }

                    notesSection

                    if reading.aiQuestion != nil || reading.savedAIResponse != nil {
                        aiSection
                    }
                }
                .padding(.horizontal)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Reading Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            originalNotes = reading.notes
        }
    }

    private var readingBackground: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.indigo.opacity(0.08),
                Color.purple.opacity(0.06)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saved Reading")
                .font(.largeTitle.bold())

            Text("A record of your cards, symbols, notes, and interpretation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private var tarotSection: some View {
        ReadingDetailSection(title: "Tarot") {
            LazyVGrid(columns: cardGridColumns, spacing: 18) {
                ForEach(reading.cardNames, id: \.self) { cardName in
                    NavigationLink {
                        CardMeaning(cardName: cardName)
                    } label: {
                        VStack(spacing: 8) {
                            CardView(card: Card(name: cardName), isFaceUp: true)
                                .frame(width: 88, height: 146)
                                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 5)

                            Text(cardName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(minHeight: 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Tap a card to view its meaning.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private var notesSection: some View {
        ReadingDetailSection(title: "Notes") {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $reading.notes)
                    .frame(minHeight: 150)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground).opacity(0.75))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                Button {
                    saveNotes()
                } label: {
                    Text(hasUnsavedNotes ? "Save Notes" : "Saved")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(hasUnsavedNotes ? Color.indigo : Color.gray.opacity(0.45))
                )
                .disabled(!hasUnsavedNotes)
                .animation(.easeInOut(duration: 0.2), value: hasUnsavedNotes)
            }
        }
    }

    private var aiSection: some View {
        ReadingDetailSection(title: "AI Interpretation") {
            VStack(alignment: .leading, spacing: 16) {
                if let aiQuestion = reading.aiQuestion, !aiQuestion.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Question")
                            .font(.headline)

                        Text(aiQuestion)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                if let savedAIResponse = reading.savedAIResponse {
                    if !savedAIResponse.summary.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Summary")
                                .font(.headline)

                            Text(savedAIResponse.summary)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }

                    if !savedAIResponse.cardByCard.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Card by Card")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(savedAIResponse.cardByCard, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundStyle(.indigo)

                                        Text(item)
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func saveNotes() {
        do {
            try modelContext.save()
            originalNotes = reading.notes
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }
}

// MARK: - Reusable Section Container

private struct ReadingDetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
    }
}
