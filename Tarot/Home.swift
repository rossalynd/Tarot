//
//  Home.swift
//  Tarot
//
//  Created by Rosie O'Marrow on 12/17/24.
//

import Foundation
import SwiftUI


struct HomeView: View {
    @Binding var navigationPath: NavigationPath


    var body: some View {
        VStack(spacing: 20) {
            Button("Start Reading") {
                navigationPath.append("SpreadSelectionView")
            }
            Button("View Saved Readings") {
                navigationPath.append("SavedReadings")
            }
            Button("View Deck") {
                navigationPath.append("FaceUpDeckView")
            }
        }
        .navigationTitle("Tarot Home")
    }
}
