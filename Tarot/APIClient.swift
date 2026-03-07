//
//  APIClient.swift
//  Tarot
//
//  Created by Rosie on 2/21/26.
//

import Foundation
final class TarotAIClient {
    // Point this at your backend (Vercel or Firebase)
    private let endpoint = URL(string: "https://YOUR_DOMAIN.com/api/tarot/interpret")!

    func interpret(question: String, selectedCards: [Card], notes: String) async throws -> TarotAIResponse {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = TarotAIRequest(
            question: question,
            cards: selectedCards.map { $0.name },
            spreadCount: selectedCards.count,
            notes: notes.isEmpty ? nil : notes
        )

        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "TarotAI", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Request failed"])
        }

        return try JSONDecoder().decode(TarotAIResponse.self, from: data)
    }
}
