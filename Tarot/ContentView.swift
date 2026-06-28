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
    @State private var readingSession = ReadingSession()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(
                navigationPath: $navigationPath,
                readingSession: readingSession
            )
            .modelContainer(for: Reading.self)
            .navigationDestination(for: String.self) { value in
                switch value {
                case "DeckView":
                    DeckView(
                        navigationPath: $navigationPath,
                        session: readingSession
                    )

                case "SpreadSelectionView":
                    SpreadSelectionView(
                        navigationPath: $navigationPath,
                        session: readingSession
                    )

                case "SavedReadings":
                    SavedReadingsView(
                        navigationPath: $navigationPath
                    )

                case "SavedReading":
                    SavedReadingsView(
                        navigationPath: $navigationPath
                    )

                case "IChingSelectionView":
                    IChingSelectionView(
                        navigationPath: $navigationPath,
                        session: readingSession
                    )

                case "RuneSelectionView":
                    RuneSelectionView(
                        navigationPath: $navigationPath,
                        session: readingSession
                    )

                case "ResultsView":
                    ResultsView(
                        navigationPath: $navigationPath,
                        session: readingSession
                    )

                case "FaceUpDeckView":
                    FaceUpDeckView(
                        navigationPath: $navigationPath
                    )

                default:
                    EmptyView()
                }
            }
            .navigationDestination(for: CardMeaningRoute.self) { route in
                CardMeaning(cardName: route.cardName)
            }
        }
        .onAppear {
            readingSession.reset()
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
