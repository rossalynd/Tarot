//
//  TarotDatabase.swift
//  Tarot
//
//  Created by Rosie on 3/7/26.
//

import Foundation



class TarotDatabase: ObservableObject {
    @Published var cards: [TarotCardMeaning] = []

    init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(
            forResource: "tarot_meanings_full_78",
            withExtension: "json"
        ) else {
            print("Could not find tarot_meanings_full_78.json")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            cards = try JSONDecoder().decode([TarotCardMeaning].self, from: data)
            print("Loaded \(cards.count) tarot meanings")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Missing key: \(key.stringValue)")
            print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug description: \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type mismatch: \(type)")
            print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug description: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(type, context) {
            print("Value not found: \(type)")
            print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug description: \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted")
            print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            print("Debug description: \(context.debugDescription)")
        } catch {
            print("Failed to load tarot meanings:")
            print(error)
        }
    }
}

struct TarotCardMeaning: Codable, Identifiable {
    let id: String            // "the_fool"
    let name: String          // "The Fool"
    let suit: String?         // "Major Arcana", "Cups", etc
    
    let coreEssence: String
    
    let lightExpression: String
    let shadowExpression: String
    
    let loveTheme: String
    let careerTheme: String
    let spiritualTheme: String
    
    let advice: String
    let emotionalTone: String
    
    let keywords: [String]
    
    let elementalEnergy: String
    let archetypeRole: String
}
