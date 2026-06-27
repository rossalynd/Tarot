//
//  IChingPatternSummaryView.swift
//  Tarot
//
//  Created by Rosie on 6/27/26.
//

import SwiftUI

struct IChingPatternSummaryView: View {
    let lines: [Int]

    private var primaryHexagram: IChingHexagram? {
        IChingHexagram.from(lines: lines, changed: false)
    }

    private var relatingHexagram: IChingHexagram? {
        IChingHexagram.from(lines: lines, changed: true)
    }

    private var changingLineNumbers: [Int] {
        lines.enumerated()
            .filter { _, value in value == 6 || value == 9 }
            .map { index, _ in index + 1 }
    }

    private var hasChangingLines: Bool {
        !changingLineNumbers.isEmpty
    }

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            HStack{
                Text("I Ching")
                    .font(.title2.bold())
                Spacer()
            }
            
            HStack(alignment: .top, spacing: 10) {
                if let primaryHexagram {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Primary Hexagram")
                            .font(.headline)

                        Text("#\(primaryHexagram.number) — \(primaryHexagram.name)")
                            .font(.body)
                    }
                }

                if let relatingHexagram, hasChangingLines {
                    Spacer()
                    Divider()
                        .frame(height: 44)
                        .padding(.horizontal, 0.5)
                        .overlay(Color.secondary.opacity(0.2))
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Relating Hexagram")
                            .font(.headline)

                        Text("#\(relatingHexagram.number) — \(relatingHexagram.name)")
                            .font(.body)
                    }
                }
            }
            
                HexagramDisplayView(lines: lines)

                
            if hasChangingLines {
                Text("Changing lines: \(changingLineNumbers.map(String.init).joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

                
            

            VStack(alignment: .leading, spacing: 16) {
                if let primaryHexagram {
                    HexagramMeaningView(
                        title: "Primary Hexagram Meaning",
                        hexagram: primaryHexagram
                    )
                }

                if let relatingHexagram, hasChangingLines {
                    Divider()

                    HexagramMeaningView(
                        title: "Relating Hexagram Meaning",
                        hexagram: relatingHexagram
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

 
}

private struct IChingHexagram {
    let number: Int
    let name: String
    let meaning: String

    static func from(lines: [Int], changed: Bool) -> IChingHexagram? {
        guard lines.count == 6 else { return nil }

        let binaryLines = lines.map { value -> String in
            switch value {
            case 6:
                return changed ? "1" : "0" // changing yin becomes yang
            case 7:
                return "1"                 // stable yang
            case 8:
                return "0"                 // stable yin
            case 9:
                return changed ? "0" : "1" // changing yang becomes yin
            default:
                return "0"
            }
        }

        let lowerTrigram = binaryLines[0...2].joined()
        let upperTrigram = binaryLines[3...5].joined()
        let key = "\(upperTrigram)-\(lowerTrigram)"

        guard let data = kingWenHexagrams[key],
              let meaning = hexagramMeanings[data.number] else {
            return nil
        }

        return IChingHexagram(
            number: data.number,
            name: data.name,
            meaning: meaning
        )
    }

    private static let kingWenHexagrams: [String: (number: Int, name: String)] = [
        "111-111": (1, "The Creative"),
        "000-000": (2, "The Receptive"),

        "010-100": (3, "Difficulty at the Beginning"),
        "001-010": (4, "Youthful Folly"),
        "010-111": (5, "Waiting"),
        "111-010": (6, "Conflict"),
        "000-010": (7, "The Army"),
        "010-000": (8, "Holding Together"),

        "011-111": (9, "Small Taming"),
        "111-110": (10, "Treading"),
        "000-111": (11, "Peace"),
        "111-000": (12, "Standstill"),

        "111-101": (13, "Fellowship"),
        "101-111": (14, "Great Possession"),
        "000-001": (15, "Modesty"),
        "100-000": (16, "Enthusiasm"),

        "110-100": (17, "Following"),
        "001-011": (18, "Work on What Has Been Spoiled"),
        "000-110": (19, "Approach"),
        "011-000": (20, "Contemplation"),

        "101-100": (21, "Biting Through"),
        "001-101": (22, "Grace"),
        "001-000": (23, "Splitting Apart"),
        "000-100": (24, "Return"),

        "111-100": (25, "Innocence"),
        "001-111": (26, "Great Taming"),
        "001-100": (27, "Nourishment"),
        "110-011": (28, "Great Preponderance"),

        "010-010": (29, "The Abysmal"),
        "101-101": (30, "The Clinging"),
        "110-001": (31, "Influence"),
        "100-011": (32, "Duration"),

        "111-001": (33, "Retreat"),
        "100-111": (34, "Great Power"),
        "101-000": (35, "Progress"),
        "000-101": (36, "Darkening of the Light"),

        "011-101": (37, "The Family"),
        "101-110": (38, "Opposition"),
        "010-001": (39, "Obstruction"),
        "100-010": (40, "Deliverance"),

        "001-110": (41, "Decrease"),
        "011-100": (42, "Increase"),
        "110-111": (43, "Breakthrough"),
        "111-011": (44, "Coming to Meet"),

        "110-000": (45, "Gathering Together"),
        "000-011": (46, "Pushing Upward"),
        "110-010": (47, "Oppression"),
        "010-011": (48, "The Well"),

        "110-101": (49, "Revolution"),
        "101-011": (50, "The Cauldron"),
        "100-100": (51, "The Shock"),
        "001-001": (52, "Keeping Still"),

        "011-001": (53, "Development"),
        "100-110": (54, "The Marrying Maiden"),
        "100-101": (55, "Abundance"),
        "101-001": (56, "The Wanderer"),

        "011-011": (57, "The Gentle"),
        "110-110": (58, "The Joyous"),
        "011-010": (59, "Dispersion"),
        "010-110": (60, "Limitation"),

        "011-110": (61, "Inner Truth"),
        "100-001": (62, "Small Preponderance"),
        "010-101": (63, "After Completion"),
        "101-010": (64, "Before Completion")
    ]

    private static let hexagramMeanings: [Int: String] = [
        1: "Creative force, initiative, vitality, and inspired action. A time to lead, begin, and shape circumstances with clarity and confidence.",
        2: "Receptivity, devotion, patience, and support. Progress comes through openness, humility, and allowing things to unfold naturally.",

        3: "The confusion and struggle of a new beginning. Growth is possible, but it requires patience, structure, and careful first steps.",
        4: "Inexperience, learning, and the need for guidance. This hexagram asks for humility, curiosity, and willingness to be taught.",
        5: "Waiting with trust and composure. Do not force the outcome; prepare yourself while circumstances ripen.",
        6: "Conflict, disagreement, or inner division. Seek fairness, avoid escalation, and know when compromise is wiser than victory.",
        7: "Discipline, organization, and collective effort. Success depends on leadership, responsibility, and a clear sense of purpose.",
        8: "Union, loyalty, and belonging. This is a time to choose your alliances carefully and strengthen sincere connections.",

        9: "Small restraint, gentle influence, and gradual refinement. Large results are not ready yet; tend to the details.",
        10: "Careful conduct in a delicate situation. Move with grace, respect boundaries, and avoid provoking unnecessary danger.",
        11: "Harmony, balance, and flourishing exchange. Heaven and earth are in accord, bringing ease, growth, and opportunity.",
        12: "Stagnation, disconnection, and blocked flow. This is a time to conserve energy and avoid investing in what cannot presently grow.",

        13: "Fellowship, shared ideals, and community. Progress comes through openness, cooperation, and joining with others in good faith.",
        14: "Abundance, talent, and great possession. Use your gifts wisely and generously; success should be guided by integrity.",
        15: "Modesty, balance, and quiet strength. True power is expressed through humility, steadiness, and self-knowledge.",
        16: "Enthusiasm, inspiration, and emotional momentum. Energy is rising; channel it into something meaningful rather than scattering it.",

        17: "Following, adaptation, and attunement. Progress comes from responding to the moment rather than rigidly insisting on your own way.",
        18: "Repairing what has decayed or been neglected. This hexagram calls for honest correction, healing old patterns, and restoring order.",
        19: "Approach, encouragement, and growing influence. Something favorable draws near, but it must be met with sincerity and care.",
        20: "Contemplation, perspective, and quiet observation. Step back, look deeply, and let insight arise before acting.",

        21: "Biting through obstacles, enforcement, and decisive clarity. A problem must be confronted directly and resolved with firmness.",
        22: "Grace, beauty, and outer refinement. Appearance matters, but it should illuminate substance rather than conceal emptiness.",
        23: "Splitting apart, erosion, and decline. Something unstable is falling away; protect what is essential and do not cling to what is collapsing.",
        24: "Return, renewal, and the first signs of revival. After darkness or error, the path back begins with a small but sincere step.",

        25: "Innocence, naturalness, and acting without ulterior motive. Stay aligned with truth and avoid overcomplicating what is simple.",
        26: "Great restraint, stored power, and disciplined preparation. Strength is gathered by holding back until the right moment.",
        27: "Nourishment, speech, and what you take in. Be mindful of what feeds your body, mind, relationships, and spirit.",
        28: "Great pressure, excess, and a structure under strain. Extraordinary circumstances require courage, flexibility, and decisive action.",

        29: "Danger, depth, and repeated trials. Move carefully through uncertainty, relying on inner truth and steady perseverance.",
        30: "Clarity, attachment, and illumination. Insight is available, but it must be sustained by devotion, discernment, and care.",
        31: "Influence, attraction, and subtle emotional exchange. Gentle openness has power; allow connection without coercion.",
        32: "Duration, commitment, and endurance. Lasting success comes through consistency, loyalty, and honoring what is sustainable.",

        33: "Retreat, withdrawal, and strategic distance. Stepping back is not defeat; it preserves strength and dignity.",
        34: "Great power, force, and confidence. Strength is available, but it must be governed by wisdom rather than impulse.",
        35: "Progress, visibility, and advancement. Conditions brighten; move forward with clarity, generosity, and purpose.",
        36: "Darkening of the light, concealment, and wounded clarity. Protect your inner truth when the outer world is unreceptive or hostile.",

        37: "Family, structure, roles, and belonging. Harmony depends on clear responsibilities, mutual respect, and emotional order.",
        38: "Opposition, difference, and divergence. People may not see alike, but small agreements and respectful distance can preserve peace.",
        39: "Obstruction, difficulty, and blocked movement. Do not force your way forward; seek help, reconsider the path, and move wisely.",
        40: "Deliverance, release, and the easing of tension. A burden can be lifted; forgive, simplify, and move out of confinement.",

        41: "Decrease, simplification, and sacrifice. Let go of excess so that what truly matters can be strengthened.",
        42: "Increase, blessing, and growth. Energy expands when generosity, movement, and sincere effort are aligned.",
        43: "Breakthrough, resolution, and speaking the truth. A decisive moment has arrived; act clearly, but without aggression.",
        44: "Coming to meet, temptation, and sudden encounter. Something powerful enters the field; engage carefully and do not surrender your center.",

        45: "Gathering together, assembly, and shared devotion. Community, ritual, and common purpose create strength.",
        46: "Pushing upward, gradual ascent, and steady effort. Advancement comes step by step through patience, humility, and persistence.",
        47: "Oppression, exhaustion, and restriction. Outer circumstances may feel confining, but inner dignity and truth remain your refuge.",
        48: "The well, nourishment, and shared resources. Return to the source; what is essential must be maintained and made accessible.",

        49: "Revolution, transformation, and necessary change. Old forms must be shed when the time is ripe for renewal.",
        50: "The cauldron, refinement, and sacred transformation. Raw material becomes nourishment through culture, wisdom, and inner alchemy.",
        51: "Shock, awakening, and sudden movement. A jolt may disturb you, but it can also clear fear and awaken truth.",
        52: "Stillness, meditation, and restraint. Stop, become quiet, and allow the restless mind to settle before proceeding.",

        53: "Development, gradual progress, and maturation. Growth is slow but enduring when built with patience and proper timing.",
        54: "The marrying maiden, secondary position, and imperfect circumstances. Adapt with grace, but do not lose yourself in unequal arrangements.",
        55: "Abundance, fullness, and a peak moment. Enjoy the brightness while it lasts, knowing that fullness naturally changes.",
        56: "The wanderer, travel, and impermanence. You are passing through; remain respectful, adaptable, and unattached.",

        57: "Gentle penetration, subtle influence, and quiet persistence. Softness, repeated steadily, can shape even resistant things.",
        58: "Joy, openness, and shared delight. Communication, pleasure, and encouragement bring connection and renewal.",
        59: "Dispersion, dissolution, and breaking apart barriers. Old rigidity melts; scattered energies can be reunited through sincerity.",
        60: "Limitation, boundaries, and measured restraint. Limits create form, but they should be humane rather than harsh.",

        61: "Inner truth, sincerity, and trust. Genuine connection arises from authenticity, openness, and alignment between heart and action.",
        62: "Small preponderance, caution, and attention to detail. This is not the time for grand gestures; small careful actions succeed.",
        63: "After completion, order, and delicate balance. A cycle has reached fulfillment, but stability requires vigilance and care.",
        64: "Before completion, transition, and unfinished transformation. The goal is near, but careful attention is needed before crossing the threshold."
    ]
}

private struct HexagramMeaningView: View {
    let title: String
    let hexagram: IChingHexagram

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text("Hexagram \(hexagram.number): \(hexagram.name)")
                .font(.subheadline.bold())

            Text(hexagram.meaning)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HexagramDisplayView: View {
    let lines: [Int]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(lines.enumerated()).reversed(), id: \.offset) { _, line in
                HStack(spacing: 10) {
                    let lineColor: Color = isChanging(line) ? .indigo : .primary

                    if isYang(line) {
                        Rectangle()
                            .fill(lineColor)
                            .frame(width: 170, height: 10)
                    } else {
                        Rectangle()
                            .fill(lineColor)
                            .frame(width: 80, height: 10)

                        Rectangle()
                            .fill(lineColor)
                            .frame(width: 80, height: 10)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: 210)
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
