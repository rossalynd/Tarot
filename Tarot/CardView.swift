//
//  CardView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI
struct CardView: View {
    let card: Card
    let isFaceUp: Bool
    
    // Helper function to check if image exists
    private func imageExists(named name: String) -> Bool {
        return UIImage(named: name) != nil
    }

    var body: some View {
        ZStack {
            if isFaceUp {
                // Check if the card image exists
                if imageExists(named: card.name) {
                    Image(card.name)
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .clipped()
                } else {
                    // Fallback when image doesn't exist
                    
                            Image("CardBack")
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .clipped()
                                
                
                }
            } else {
                // Use the card back image
                Image("CardBack")
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .clipped()
            }
           
        }
        .aspectRatio(2/3, contentMode: .fit)
        
    }
}
#Preview {
    CardView(card: Card(name: "The Sun",), isFaceUp: true)
        .modelContainer(for: Reading.self, inMemory: true)
}
