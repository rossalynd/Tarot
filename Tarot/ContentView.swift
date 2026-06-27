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
    @State private var selectedRune: String? = nil
    @State private var hexagramLines: [Int] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .modelContainer(for: Reading.self)
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "DeckView":
                        DeckView(
                            navigationPath: $navigationPath,
                            selectedCards: $selectedCards,
                            spreadCount: 4
                        )

                    case "SpreadSelectionView":
                        SpreadSelectionView(
                            navigationPath: $navigationPath,
                            selectedCards: $selectedCards
                        )

                    case "SavedReadings":
                        SavedReadingsView(navigationPath: $navigationPath)

                    case "SavedReading":
                        SavedReadingsView(navigationPath: $navigationPath)

                    case "IChingSelectionView":
                        IChingSelectionView(
                            navigationPath: $navigationPath,
                            hexagramLines: $hexagramLines
                        )

                    case "RuneSelectionView":
                        RuneSelectionView(
                            navigationPath: $navigationPath,
                            selectedRune: $selectedRune
                        )

                    case "ResultsView":
                        ResultsView(
                            navigationPath: $navigationPath,
                            selectedCards: $selectedCards,
                            selectedRune: $selectedRune,
                            hexagramLines: $hexagramLines
                        )

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
        .onAppear {
            selectedCards = []
            selectedRune = nil
            hexagramLines = []
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
