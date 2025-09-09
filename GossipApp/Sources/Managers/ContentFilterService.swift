//
//  ContentFilterService.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/09.
//

import Foundation

@MainActor
class ContentFilterService: ObservableObject {
    private let bannedWords: [String] = [
        "시발", "씨발", "개새끼", "병신", "좆", "존나", "개놈", "년", "놈", "디져", "뒤져",
        "테러", "마약", "보지", "자지", "따먹", "강간", "섹스", "쎅스", "빠구리", "창녀", "창년", "창놈"
    ]
    
    func filterContent(_ content: String) async -> String {
        var filteredContent = content
        for bannedWord in bannedWords {
            filteredContent = filteredContent.replacingOccurrences(of: bannedWord, with: String(repeating: "*", count: bannedWord.count))
        }
        return filteredContent
    }
}
