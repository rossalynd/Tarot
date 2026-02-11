//
//  DataModels.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//
import SwiftData
import SwiftUI

@Model
class Card {
    var id: UUID = UUID()
    var name: String
    var isSelected: Bool = false

    init(name: String) {
        self.name = name
       
    }
}

@Model
class Reading {
    var id: UUID = UUID()
    var date: Date
    var cardsChosen: [Card]
    var notes: String

    init(cardsChosen: [Card], notes: String) {
        self.date = Date()
        self.cardsChosen = cardsChosen
        self.notes = notes
    }
    
}

@Model
class TarotMeanings {
    var id: Double
    var meaning: String
    
    init(id: Double, meaning: String) {
        self.id = id
        self.meaning = meaning
    }
}


