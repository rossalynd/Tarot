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
    @Bindable var readingSession: ReadingSession

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.black,
                    Color.indigo.opacity(0.95),
                    Color.indigo.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative glow
            Circle()
                .fill(Color.purple.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: -120, y: -250)

            Circle()
                .fill(Color.blue.opacity(0.14))
                .frame(width: 220, height: 220)
                .blur(radius: 40)
                .offset(x: 120, y: 260)
            
            
            ShinyViewWrapper()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .rotationEffect(.degrees(35))
                .ignoresSafeArea(edges: .all)
                        .blendMode(.screen)

                        .opacity(0.435)
                .mask(
                    Rectangle()
                                   .fill(
                                       ImagePaint(
                                           image: Image("stars"),
                                           scale: 0.5
                                       )
                                   )
                                   .ignoresSafeArea(edges: .all)
                )

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 10) {
                      

                        Text("Tarot")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        Text("Choose your path and explore your readings")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 30)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 16) {
                        TarotMenuCard(
                            title: "Start Reading",
                            subtitle: "Begin a new spread and reveal your cards",
                            systemImage: "moon.stars.fill"
                        ) {
                            readingSession.reset()
                            navigationPath.append("SpreadSelectionView")
                        }

                        TarotMenuCard(
                            title: "View Saved Readings",
                            subtitle: "Revisit past spreads and reflections",
                            systemImage: "book.closed.fill"
                        ) {
                            navigationPath.append("SavedReadings")
                        }

                        TarotMenuCard(
                            title: "View Deck",
                            subtitle: "Browse every card in the deck face up",
                            systemImage: "square.stack.3d.up.fill"
                        ) {
                            navigationPath.append("FaceUpDeckView")
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
        }
        .navigationDestination(for: String.self) { route in
            switch route {
            

            case "SavedReadings":
                SavedReadingsView(
                    navigationPath: $navigationPath
                )

            case "SpreadSelectionView":
                SpreadSelectionView(
                    navigationPath: $navigationPath,
                    session: readingSession
                )

            case "DeckView":
                DeckView(
                    navigationPath: $navigationPath,
                    session: readingSession
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
                FaceUpDeckView(navigationPath: $navigationPath)

            default:
                EmptyView()
            }
        }
    }
}

struct TarotMenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.12))
                        .frame(width: 54, height: 54)

                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color("iconColor"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

