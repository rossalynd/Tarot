//
//  TarotSchemaV1.swift
//  Tarot
//
//  Created by Rosie on 6/27/26.
//


//
//  TarotSchema.swift
//  Tarot
//

import Foundation
import SwiftData

enum TarotSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Reading.self
        ]
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
    }
}

enum TarotSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Reading.self
        ]
    }

    @Model
    final class Reading {
        var id: UUID
        var date: Date
        var cardNames: [String]
        var notes: String
        var rune: String?
        var hexagramLinesRaw: String

        // New fields in V2
        var aiQuestion: String?
        var aiResponseJSON: String?

        init(
            cardNames: [String],
            notes: String,
            rune: String? = nil,
            hexagramLines: [Int] = [],
            aiQuestion: String? = nil,
            aiResponseJSON: String? = nil
        ) {
            self.id = UUID()
            self.date = Date()
            self.cardNames = cardNames
            self.notes = notes
            self.rune = rune
            self.hexagramLinesRaw = hexagramLines.map(String.init).joined(separator: ",")
            self.aiQuestion = aiQuestion
            self.aiResponseJSON = aiResponseJSON
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

        var savedAIResponse: TarotAIResponse? {
            get {
                guard let aiResponseJSON,
                      let data = aiResponseJSON.data(using: .utf8)
                else {
                    return nil
                }

                return try? JSONDecoder().decode(TarotAIResponse.self, from: data)
            }
            set {
                aiResponseJSON = Self.encodeAIResponse(newValue)
            }
        }

        var iChingHexagramNumber: Int? {
            IChingHexagramLookup.number(for: hexagramLines)
        }

        var iChingChangingLines: [Int] {
            IChingHexagramLookup.changingLines(for: hexagramLines)
        }

        private static func encodeAIResponse(_ response: TarotAIResponse?) -> String? {
            guard let response else { return nil }

            do {
                let data = try JSONEncoder().encode(response)
                return String(data: data, encoding: .utf8)
            } catch {
                print("Failed to encode AI response: \(error.localizedDescription)")
                return nil
            }
        }
        
        static func encodeAIResponseForSave(_ response: TarotAIResponse?) -> String? {
            encodeAIResponse(response)
        }
    }
}

typealias Reading = TarotSchemaV2.Reading
