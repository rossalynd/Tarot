//
//  ReadingSession.swift
//  Tarot
//
//  Created by Rosie on 6/27/26.
//
import Foundation

import Observation
@Observable
final class ReadingSession {
    var selectedCards: [Card] = []
    var selectedRune: String? = nil
    var hexagramLines: [Int] = []
    var spreadPositions: [String] = []

    var spreadCount: Int {
        spreadPositions.count
    }

    func reset() {
        selectedCards.removeAll()
        selectedRune = nil
        hexagramLines.removeAll()
        spreadPositions.removeAll()
    }
}
