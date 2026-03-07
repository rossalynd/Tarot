//
//  ContentView.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var selectedCards: [Card] = []
    

    var body: some View {
            // Always apply modelContainer at the root level
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath).modelContainer(for: Reading.self)
                .navigationDestination(for: String.self) { value in
                                    switch value {
                                    case "DeckView":
                                        DeckView(navigationPath: $navigationPath, selectedCards: $selectedCards, spreadCount: 3)
                                    case "SpreadSelectionView":
                                        SpreadSelectionView(navigationPath: $navigationPath, selectedCards: $selectedCards)
                                    case "SavedReadings":
                                        SavedReadingsView(navigationPath: $navigationPath)
                                    case "SavedReading":
                                        SavedReadingsView(navigationPath: $navigationPath)
                                    case "ResultsView":
                                        ResultsView(navigationPath: $navigationPath, selectedCards: $selectedCards)
                                    case "FaceUpDeckView":
                                        FaceUpDeckView(navigationPath: $navigationPath)
                                        
                                    default:
                                        EmptyView()
                                    }
                                }
                .navigationDestination(for: CardMeaningRoute.self) { route in
                    CardMeaning(cardName: route.cardName)
                }
               }
        .onAppear() {
            selectedCards = []
        }
        
               
        }
    


    }
struct CardMeaningRoute: Hashable {
    let cardName: String
}
#Preview {
    ContentView()
        .modelContainer(for: Reading.self, inMemory: true)
}
