//
//  APIClient.swift
//  Tarot
//
//  Created by Rosie on 2/21/26.
//

import Foundation

final class TarotAIClient {
    private let endpoint = URL(string: "https://us-central1-tarot-f9b49.cloudfunctions.net/interpretTarot")!

    func interpret(
        question: String,
        selectedCards: [Card],
        notes: String,
        rune: String?,
        hexagramLines: [Int]
    ) async throws -> TarotAIResponse {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let hexagramNumber = IChingHexagramLookup.number(for: hexagramLines)
        let changingLines = IChingHexagramLookup.changingLines(for: hexagramLines)

        let payload = TarotAIRequest(
            question: question,
            cards: selectedCards.map { $0.name },
            spreadCount: selectedCards.count,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            rune: rune,
            iChingHexagramNumber: hexagramNumber,
            iChingChangingLines: changingLines.isEmpty ? nil : changingLines
        )

        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw NSError(
                domain: "TarotAI",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Request failed"
                ]
            )
        }

        return try JSONDecoder().decode(TarotAIResponse.self, from: data)
    }
}
