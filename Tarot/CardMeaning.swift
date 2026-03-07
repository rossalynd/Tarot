//
//  CardMeaning.swift
//  Tarot
//
//  Created by Rosie on 3/7/26.
//


import SwiftUI

struct CardMeaning: View {
    let cardName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(cardName)
                .font(.largeTitle.bold())
            
            Text("Card meaning goes here.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle(cardName)
        .navigationBarTitleDisplayMode(.inline)
    }
}