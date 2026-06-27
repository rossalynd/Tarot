//
//  RuneSummaryView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 6/27/26.
//

import SwiftUI

struct RuneSummaryView: View {
    let rune: String
    var showTitle: Bool = true
    var imageSize: CGFloat = 110

    private var info: RuneInfo {
        RuneInfo(for: rune)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle {
                Text("Rune")
                    .font(.title2.bold())
            }

            HStack(alignment: .center, spacing: 16) {
                runeImage

                VStack(alignment: .leading, spacing: 4) {
                    Text(info.name)
                        .font(.headline)

                    Text(info.meaning)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var runeImage: some View {
        if let imageName = info.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .accessibilityLabel(info.name)
        } else {
            Text(rune)
                .font(.system(size: imageSize * 0.44))
                .frame(width: imageSize, height: imageSize)
                .accessibilityLabel(info.name)
        }
    }
}

struct RuneInfo {
    let symbol: String
    let name: String
    let imageName: String?
    let meaning: String

    init(for rune: String) {
        self.symbol = rune

        switch rune {
        case "ᚠ":
            self.name = "Fehu"
            self.imageName = "Fehu"
            self.meaning = "Wealth, abundance, prosperity, resources, success"

        case "ᚢ":
            self.name = "Uruz"
            self.imageName = "Uruz"
            self.meaning = "Strength, vitality, endurance, primal power, health"

        case "ᚦ":
            self.name = "Thurisaz"
            self.imageName = "Thurisaz"
            self.meaning = "Protection, conflict, challenge, force, boundaries"

        case "ᚨ":
            self.name = "Ansuz"
            self.imageName = "Ansuz"
            self.meaning = "Wisdom, communication, divine message, inspiration"

        case "ᚱ":
            self.name = "Raidho"
            self.imageName = "Raidho"
            self.meaning = "Journey, movement, travel, rhythm, right direction"

        case "ᚲ":
            self.name = "Kenaz"
            self.imageName = "Kenaz"
            self.meaning = "Torch, knowledge, creativity, illumination, skill"

        case "ᚷ":
            self.name = "Gebo"
            self.imageName = "Gebo"
            self.meaning = "Gift, exchange, generosity, partnership, balance"

        case "ᚹ":
            self.name = "Wunjo"
            self.imageName = "Wunjo"
            self.meaning = "Joy, harmony, comfort, fulfillment, belonging"

        case "ᚺ":
            self.name = "Hagalaz"
            self.imageName = "Hagalaz"
            self.meaning = "Disruption, hail, transformation, chaos, necessary change"

        case "ᚾ":
            self.name = "Naubiz"
            self.imageName = "Naubiz"
            self.meaning = "Need, constraint, survival, resistance, inner fire"

        case "ᛁ":
            self.name = "Isa"
            self.imageName = "Isa"
            self.meaning = "Ice, stillness, pause, focus, preservation"

        case "ᛃ":
            self.name = "Jera"
            self.imageName = "Jera"
            self.meaning = "Harvest, cycles, patience, reward, natural timing"

        case "ᛇ":
            self.name = "Ihwa-Eihwaz"
            self.imageName = "Ihwa-Eihwaz"
            self.meaning = "Yew tree, endurance, protection, death and rebirth, resilience"

        case "ᛈ":
            self.name = "Perthro"
            self.imageName = "Perthro"
            self.meaning = "Mystery, fate, chance, hidden knowledge, the unknown"

        case "ᛉ":
            self.name = "Elhaz"
            self.imageName = "Elhaz"
            self.meaning = "Protection, higher guidance, sanctuary, spiritual connection"

        case "ᛋ":
            self.name = "Sowilo"
            self.imageName = "Sowilo"
            self.meaning = "Sun, success, clarity, life force, victory"

        case "ᛏ":
            self.name = "Tiwaz"
            self.imageName = "Tiwaz"
            self.meaning = "Courage, justice, honor, leadership, sacrifice"

        case "ᛒ":
            self.name = "Berkano"
            self.imageName = "Berkano"
            self.meaning = "Birch, growth, renewal, fertility, nurturing"

        case "ᛖ":
            self.name = "Ehwaz"
            self.imageName = "Ehwaz"
            self.meaning = "Horse, trust, partnership, movement, loyalty"

        case "ᛗ":
            self.name = "Mannaz"
            self.imageName = "Mannaz"
            self.meaning = "Humanity, self, community, awareness, cooperation"

        case "ᛚ":
            self.name = "Laguz"
            self.imageName = "Laguz"
            self.meaning = "Water, intuition, emotion, flow, dreams"

        case "ᛜ":
            self.name = "Ingwaz"
            self.imageName = "Ingwaz"
            self.meaning = "Potential, fertility, seed energy, inner growth, completion"

        case "ᛞ":
            self.name = "Dagaz"
            self.imageName = "Dagaz"
            self.meaning = "Dawn, breakthrough, awakening, transformation, hope"

        case "ᛟ":
            self.name = "Othala"
            self.imageName = "Othala"
            self.meaning = "Heritage, ancestry, home, inheritance, belonging"

        default:
            self.name = "Rune"
            self.imageName = nil
            self.meaning = "A symbol has appeared."
        }
    }
}
