//
//  IChingSelectionView.swift
//  Tarot
//
//  Created by Rosie on 4/9/26.
//

import SwiftUI
import AVFoundation

struct IChingSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var hexagramLines: [Int]

    @State private var coins: [SpinningCoin] = []
    @State private var isTossing = false
    @State private var lineJustCompleted: Int? = nil
    @State private var hasStarted = false

    @State private var coinAudioPlayers: [AVAudioPlayer] = []

    private let coinSoundNames = [
        "coinToss1",
        "coinToss2",
        "coinToss3"
    ]

    var body: some View {
        VStack(spacing: 28) {
            Text("Choose")
                .font(.largeTitle.bold())

            Text("Line \(min(hexagramLines.count + 1, 6)) of 6")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                ForEach(coins) { coin in
                    Button {
                        stopCoin(coin)
                    } label: {
                        CoinView(coin: coin)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isTossing || coin.isStopped || lineJustCompleted != nil)
                }
            }
            .frame(height: 150)

            Text(instructionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(minHeight: 24)

            if let lineJustCompleted {
                VStack(spacing: 6) {
                    Text("Line Complete")
                        .font(.headline)

                    Text(lineMeaning(for: lineJustCompleted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity)
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
            guard !hasStarted else { return }

            hasStarted = true

            if hexagramLines.count >= 6 {
                navigationPath.append("RuneSelectionView")
            } else {
                startToss()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var instructionText: String {
        let stoppedCount = coins.filter(\.isStopped).count

        if isTossing {
            return "Tap each spinning coin to stop it."
        } else if stoppedCount == 3 {
            return "Reading the line..."
        } else if hexagramLines.count < 6 {
            return "Preparing the next toss..."
        } else {
            return ""
        }
    }

    private func startToss() {
        guard hexagramLines.count < 6 else {
            navigationPath.append("RuneSelectionView")
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            lineJustCompleted = nil
            coins = [
                SpinningCoin(),
                SpinningCoin(),
                SpinningCoin()
            ]
            isTossing = true
        }
    }

    private func stopCoin(_ coin: SpinningCoin) {
        guard let index = coins.firstIndex(where: { $0.id == coin.id }) else { return }
        guard !coins[index].isStopped else { return }
        guard isTossing else { return }
        guard lineJustCompleted == nil else { return }

        playRandomCoinSound()

        let result = currentCoinResult(for: coin)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            coins[index].result = result
            coins[index].isStopped = true
        }

        let stoppedCount = coins.filter(\.isStopped).count

        if stoppedCount == 3 {
            completeLine()
        }
    }

    private func playRandomCoinSound() {
        guard let soundName = coinSoundNames.randomElement() else { return }

        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find sound file named \(soundName).mp3")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()

            coinAudioPlayers.append(player)

            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.2) {
                coinAudioPlayers.removeAll { $0 === player }
            }
        } catch {
            print("Failed to play coin sound: \(error.localizedDescription)")
        }
    }

    private func currentCoinResult(for coin: SpinningCoin) -> CoinResult {
        let time = Date().timeIntervalSinceReferenceDate
        let cycleSpeed = 16.0

        let cycle = Int((time + coin.offset) * cycleSpeed)

        return cycle.isMultiple(of: 2) ? .heads : .tails
    }

    private func completeLine() {
        isTossing = false

        let total = coins
            .compactMap(\.result)
            .map(\.value)
            .reduce(0, +)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation {
                lineJustCompleted = total
                hexagramLines.append(total)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    lineJustCompleted = nil
                    coins = []
                }

                if hexagramLines.count >= 6 {
                    navigationPath.append("RuneSelectionView")
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        startToss()
                    }
                }
            }
        }
    }

    private func lineMeaning(for total: Int) -> String {
        switch total {
        case 6:
            return "Changing Shadow"
        case 7:
            return "Stable Light"
        case 8:
            return "Stable Shadow"
        case 9:
            return "Changing Light"
        default:
            return "Line \(total)"
        }
    }
}

private struct CoinView: View {
    let coin: SpinningCoin

    var body: some View {
        ZStack {
            if coin.isStopped, let result = coin.result {
                Image(result.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                    .transition(.scale.combined(with: .opacity))
            } else {
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let cycleSpeed = 16.0

                    let cycle = Int((time + coin.offset) * cycleSpeed)
                    let isShowingHeads = cycle.isMultiple(of: 2)

                    let angle = (time + coin.offset) * 720
                    let radians = angle * .pi / 180
                    let widthScale = max(0.12, abs(cos(radians)))

                    ZStack {
                        if widthScale < 0.18 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.gray.opacity(0.75),
                                            Color.white.opacity(0.9),
                                            Color.gray.opacity(0.65)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 12, height: 108)
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 5)
                        } else {
                            Image(isShowingHeads ? "CoinHeads" : "CoinTails")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .scaleEffect(x: widthScale, y: 1.0)
                                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                        }
                    }
                }
                .frame(width: 120, height: 120)
            }
        }
        .frame(width: 125, height: 125)
    }
}

private struct SpinningCoin: Identifiable {
    let id = UUID()
    var result: CoinResult? = nil
    var isStopped = false

    let offset: Double = Double.random(in: 0...1)
}

private enum CoinResult {
    case heads
    case tails

    var imageName: String {
        switch self {
        case .heads:
            return "CoinHeads"
        case .tails:
            return "CoinTails"
        }
    }

    var value: Int {
        switch self {
        case .heads:
            return 3
        case .tails:
            return 2
        }
    }
}
