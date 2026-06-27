//
//  RuneSelectionView.swift
//  Tarot
//
//  Created by Rosie on 4/9/26.
//


//
//  RuneSelectionView.swift
//  Tarot
//
//  Created by ChatGPT on 4/9/26.
//

import SwiftUI

struct RuneSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedRune: String?

    @State private var runeChoices: [RuneChoice] = RuneChoice.makeChoices()
    @State private var revealedRuneID: UUID? = nil

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose a Symbol")
                .font(.largeTitle.bold())

            Text("Select one")
                .font(.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(runeChoices) { choice in
                    Button {
                        reveal(choice)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 130)

                            if revealedRuneID == choice.id {
                                Text(choice.rune)
                                    .font(.system(size: 42))
                                    .foregroundStyle(.primary)
                            } else {
                                Image("CardBack")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(revealedRuneID != nil)
                }
            }

            Spacer()
        }
        .padding()
    }

    private func reveal(_ choice: RuneChoice) {
        revealedRuneID = choice.id
        selectedRune = choice.rune

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            navigationPath.append("ResultsView")
        }
    }
}

private struct RuneChoice: Identifiable {
    let id = UUID()
    let rune: String

    static func makeChoices() -> [RuneChoice] {
        let runePool = ["ᚠ", "ᚢ", "ᚦ", "ᚨ", "ᚱ", "ᚲ", "ᚷ", "ᚹ", "ᚺ", "ᚾ", "ᛁ", "ᛃ"]
            .shuffled()

        return Array(runePool.prefix(6)).map { RuneChoice(rune: $0) }
    }
}