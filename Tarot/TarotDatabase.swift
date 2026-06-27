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
        if let url = Bundle.main.url(forResource: "tarot_meanings", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            cards = try! JSONDecoder().decode([TarotCardMeaning].self, from: data)
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
