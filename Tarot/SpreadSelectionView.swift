//
//  SpreadSelectionView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI

struct SpreadSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedCards: [Card]
    @State private var spreadCount: Int = 4
    var body: some View {
        VStack {
            Text("Choose Spread")
            Picker("Number of Cards", selection: $spreadCount) {
                ForEach(1...12, id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            NavigationLink(destination: DeckView(navigationPath: $navigationPath, selectedCards: $selectedCards, spreadCount: spreadCount)) {
                Text("Choose Cards")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            
        }
        
    }
}

