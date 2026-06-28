//
//  RuneSelectionView.swift
//  Tarot
//
//  Created by Rosie on 4/9/26.
//

import SwiftUI
import AVFoundation

struct RuneSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedRune: String?

    @State private var chosenRune: RuneChoice? = nil
    @State private var isDrawingRune = false
    @State private var hasDrawnRune = false

    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose a Symbol")
                .font(.largeTitle.bold())

            Text(chosenRune == nil ? "Tap the pouch to draw your rune" : "Your rune has been drawn")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            ZStack {
                if let chosenRune {
                    Image(chosenRune.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .offset(y: hasDrawnRune ? -170 : 20)
                        .scaleEffect(hasDrawnRune ? 1.0 : 0.35)
                        .opacity(hasDrawnRune ? 1 : 0)
                        .zIndex(1)
                        .animation(
                            .spring(response: 0.65, dampingFraction: 0.75),
                            value: hasDrawnRune
                        )
                }

                Button {
                    drawRune()
                } label: {
                    Image("Pouch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240)
                        .scaleEffect(isDrawingRune ? 0.96 : 1.0)
                        .animation(
                            .spring(response: 0.25, dampingFraction: 0.55),
                            value: isDrawingRune
                        )
                }
                .buttonStyle(.plain)
                .disabled(chosenRune != nil)
                .zIndex(2)
            }
            .frame(height: 360)

            VStack(spacing: 16) {
                if chosenRune == nil {
                    Text("The pouch is waiting...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let chosenRune {
                    Text(chosenRune.name)
                        .font(.title2.bold())
                        .transition(.opacity)

                    Button {
                        navigationPath.append("ResultsView")
                    } label: {
                        Text("Continue to Reading")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.easeInOut, value: chosenRune != nil)

            Spacer()
        }
        .padding()
    }

    private func drawRune() {
        guard chosenRune == nil else { return }

        playSound(named: "runeReveal")

        let rune = RuneChoice.allCases.randomElement()!

        chosenRune = rune
        selectedRune = rune.symbol

        isDrawingRune = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isDrawingRune = false
            hasDrawnRune = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
            playSound(named: "runeSelect")
        }
    }

    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find sound file named \(soundName).mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play \(soundName): \(error.localizedDescription)")
        }
    }
}

private struct RuneChoice: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let imageName: String

    static let allCases: [RuneChoice] = [
        RuneChoice(symbol: "ᚠ", name: "Fehu", imageName: "Fehu"),
        RuneChoice(symbol: "ᚢ", name: "Uruz", imageName: "Uruz"),
        RuneChoice(symbol: "ᚦ", name: "Thurisaz", imageName: "Thurisaz"),
        RuneChoice(symbol: "ᚨ", name: "Ansuz", imageName: "Ansuz"),
        RuneChoice(symbol: "ᚱ", name: "Raidho", imageName: "Raidho"),
        RuneChoice(symbol: "ᚲ", name: "Kenaz", imageName: "Kenaz"),
        RuneChoice(symbol: "ᚷ", name: "Gebo", imageName: "Gebo"),
        RuneChoice(symbol: "ᚹ", name: "Wunjo", imageName: "Wunjo"),
        RuneChoice(symbol: "ᚺ", name: "Hagalaz", imageName: "Hagalaz"),
        RuneChoice(symbol: "ᚾ", name: "Naubiz", imageName: "Naubiz"),
        RuneChoice(symbol: "ᛁ", name: "Isa", imageName: "Isa"),
        RuneChoice(symbol: "ᛃ", name: "Jera", imageName: "Jera"),
        RuneChoice(symbol: "ᛇ", name: "Ihwa-Eihwaz", imageName: "Ihwa-Eihwaz"),
        RuneChoice(symbol: "ᛈ", name: "Perthro", imageName: "Perthro"),
        RuneChoice(symbol: "ᛉ", name: "Elhaz", imageName: "Elhaz"),
        RuneChoice(symbol: "ᛋ", name: "Sowilo", imageName: "Sowilo"),
        RuneChoice(symbol: "ᛏ", name: "Tiwaz", imageName: "Tiwaz"),
        RuneChoice(symbol: "ᛒ", name: "Berkano", imageName: "Berkano"),
        RuneChoice(symbol: "ᛖ", name: "Ehwaz", imageName: "Ehwaz"),
        RuneChoice(symbol: "ᛗ", name: "Mannaz", imageName: "Mannaz"),
        RuneChoice(symbol: "ᛚ", name: "Laguz", imageName: "Laguz"),
        RuneChoice(symbol: "ᛜ", name: "Ingwaz", imageName: "Ingwaz"),
        RuneChoice(symbol: "ᛞ", name: "Dagaz", imageName: "Dagaz"),
        RuneChoice(symbol: "ᛟ", name: "Othala", imageName: "Othala")
    ]
}
