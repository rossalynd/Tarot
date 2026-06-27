//
//  IChingSelectionView.swift
//  Tarot
//
//  Created by ChatGPT on 4/9/26.
//

import SwiftUI

struct IChingSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var hexagramLines: [Int]

    @State private var currentSelections: [Int] = []
    @State private var revealedCards: [HiddenCoinChoice] = []
    @State private var lineJustCompleted: Int? = nil

    var body: some View {
        VStack(spacing: 28) {
            Text("Choose")
                .font(.largeTitle.bold())

            Text("Line \(hexagramLines.count + 1) of 6")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                ForEach(revealedCards) { choice in
                    Button {
                        choose(choice)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.08))
                                .frame(width: 120, height: 170)

                            if choice.isRevealed {
                                Text(choice.value == 3 ? "Light" : "Shadow")
                                    .font(.headline.bold())
                                    .foregroundStyle(.primary)
                            } else {
                                Image("CardBack")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 170)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(choice.isRevealed || lineJustCompleted != nil)
                }
            }

            VStack(spacing: 8) {
                Text("Selections for this line")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(index < currentSelections.count ? Color.blue.opacity(0.2) : Color.gray.opacity(0.12))
                            .frame(width: 60, height: 60)
                            .overlay {
                                if index < currentSelections.count {
                                    Text("\(currentSelections[index])")
                                        .font(.headline)
                                }
                            }
                    }
                }
            }

            if !hexagramLines.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pattern so far")
                        .font(.headline)

                    HexagramDisplayView(lines: hexagramLines)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if revealedCards.isEmpty {
                revealedCards = makeChoices()
            }

            if hexagramLines.count >= 6 {
                navigationPath.append("RuneSelectionView")
            }
        }
    }

    private func choose(_ choice: HiddenCoinChoice) {
        guard lineJustCompleted == nil else { return }
        guard let selectedIndex = revealedCards.firstIndex(where: { $0.id == choice.id }) else { return }

        let selectedValue = revealedCards[selectedIndex].value

        for index in revealedCards.indices {
            revealedCards[index].isRevealed = false
        }

        revealedCards[selectedIndex].isRevealed = true
        currentSelections.append(selectedValue)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if currentSelections.count == 3 {
                let total = currentSelections.reduce(0, +)
                lineJustCompleted = total
                hexagramLines.append(total)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    currentSelections = []
                    lineJustCompleted = nil

                    if hexagramLines.count == 6 {
                        navigationPath.append("RuneSelectionView")
                    } else {
                        revealedCards = makeChoices()
                    }
                }
            } else {
                revealedCards = makeChoices()
            }
        }
    }

    private func makeChoices() -> [HiddenCoinChoice] {
        let values = [2, 3].shuffled()
        return [
            HiddenCoinChoice(value: values[0]),
            HiddenCoinChoice(value: values[1])
        ]
    }
}

private struct HiddenCoinChoice: Identifiable {
    let id = UUID()
    let value: Int
    var isRevealed: Bool = false
}
