//
//  DataModels.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftData
import SwiftUI

struct Card: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var isSelected: Bool = false

    init(name: String) {
        self.name = name
    }
}

@Model
final class Reading {
    var id: UUID
    var date: Date
    var cardNames: [String]
    var notes: String
    var rune: String?
    var hexagramLinesRaw: String

    init(
        cardNames: [String],
        notes: String,
        rune: String? = nil,
        hexagramLines: [Int] = []
    ) {
        self.id = UUID()
        self.date = Date()
        self.cardNames = cardNames
        self.notes = notes
        self.rune = rune
        self.hexagramLinesRaw = hexagramLines.map(String.init).joined(separator: ",")
    }

    var hexagramLines: [Int] {
        get {
            hexagramLinesRaw
                .split(separator: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        }
        set {
            hexagramLinesRaw = newValue.map(String.init).joined(separator: ",")
        }
    }

    var iChingHexagramNumber: Int? {
        IChingHexagramLookup.number(for: hexagramLines)
    }

    var iChingChangingLines: [Int] {
        IChingHexagramLookup.changingLines(for: hexagramLines)
    }
}

struct TarotMeanings: Identifiable, Hashable, Codable {
    var id: Double
    var meaning: String

    init(id: Double, meaning: String) {
        self.id = id
        self.meaning = meaning
    }
}

struct TarotAIRequest: Codable {
    let question: String
    let cards: [String]
    let spreadCount: Int
    let notes: String?
    let rune: String?
    let iChingHexagramNumber: Int?
    let iChingChangingLines: [Int]?
}

struct TarotAIResponse: Codable {
    let summary: String
    let cardByCard: [String]
    let advice: [String]
    let journalPrompts: [String]
}

enum IChingHexagramLookup {
    // Key format:
    // - 6 characters
    // - bottom line to top line
    // - yang = 1
    // - yin = 0
    static let hexagramsByBinary: [String: Int] = [
        "111111": 1,
        "000000": 2,
        "100010": 3,
        "010001": 4,
        "111010": 5,
        "010111": 6,
        "010000": 7,
        "000010": 8,
        "111011": 9,
        "110111": 10,
        "111000": 11,
        "000111": 12,
        "101111": 13,
        "111101": 14,
        "001000": 15,
        "000100": 16,
        "100110": 17,
        "011001": 18,
        "110000": 19,
        "000011": 20,
        "100101": 21,
        "101001": 22,
        "000001": 23,
        "100000": 24,
        "100111": 25,
        "111001": 26,
        "100001": 27,
        "011110": 28,
        "010010": 29,
        "101101": 30,
        "001110": 31,
        "011100": 32,
        "001111": 33,
        "111100": 34,
        "000101": 35,
        "101000": 36,
        "101011": 37,
        "110101": 38,
        "001010": 39,
        "010100": 40,
        "110001": 41,
        "100011": 42,
        "111110": 43,
        "011111": 44,
        "000110": 45,
        "011000": 46,
        "010110": 47,
        "011010": 48,
        "101110": 49,
        "011101": 50,
        "100100": 51,
        "001001": 52,
        "001011": 53,
        "110100": 54,
        "101100": 55,
        "001101": 56,
        "011011": 57,
        "110110": 58,
        "010011": 59,
        "110010": 60,
        "110011": 61,
        "001100": 62,
        "101010": 63,
        "010101": 64
    ]

    static func number(for rawLines: [Int]) -> Int? {
        guard rawLines.count == 6 else { return nil }

        let bits = rawLines.map { line -> String in
            switch line {
            case 7, 9:
                return "1" // yang
            case 6, 8:
                return "0" // yin
            default:
                return ""
            }
        }

        guard bits.allSatisfy({ !$0.isEmpty }) else { return nil }

        let key = bits.joined()
        return hexagramsByBinary[key]
    }

    static func changingLines(for rawLines: [Int]) -> [Int] {
        guard rawLines.count == 6 else { return [] }

        return rawLines.enumerated().compactMap { index, line in
            switch line {
            case 6, 9:
                return index + 1 // line numbers are 1...6 from bottom to top
            default:
                return nil
            }
        }
    }
}
