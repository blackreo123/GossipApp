//
//  ComposeButtonView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/03.
//

import Foundation
import SwiftUI

struct ComposeButtonView: View {
    @ObservedObject var gossipManager: GossipManager
    @ObservedObject var toastManager: ToastManager
    @StateObject private var contentFilter = ContentFilterService()
    @Binding var isComposing: Bool
    @Binding var newMessage: String
    
    private let successMessages = [
        "불만을 소리쳤습니다...",
        "마음이 한결 가벼워졌어요",
        "속이 시원하게 털어냈네요!",
        "답답함을 날려버렸습니다!",
        "세상에 외쳤습니다!"
    ]
    
    var body: some View {
        if isComposing {
            VStack(spacing: 16) {
                TextField("뒷담화를 입력하세요...", text: $newMessage)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                    .foregroundColor(.white)
                
                HStack {
                    Text("\(newMessage.count)/50")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button("취소") {
                        isComposing = false
                        newMessage = ""
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Button("전송") {
                        Task {
                            do {
                                let filterdMessage = await contentFilter.filterContent(newMessage)
                                try await gossipManager.sendGossip(filterdMessage)
                                isComposing = false
                                newMessage = ""
                                toastManager.showSuccess(successMessages.randomElement() ?? "불만을 소리쳤습니다...")
                            } catch let error as GossipError {
                                toastManager.show(error.toastMessage)
                            } catch {
                                toastManager.showError("An unexpected error occurred.")
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .disabled(newMessage.isEmpty || newMessage.count > 50)
                }
            }
            .padding(.horizontal, 24)
        } else {
            Button(action: {
                guard gossipManager.dailyUsage < 3 else { return }
                isComposing = true
            }) {
                HStack(spacing: 8) {
                    if gossipManager.dailyUsage < 3 {
                        Image(systemName: "plus")
                        Text("뒷담화")
                    } else {
                        Text("내일 또 만나요")
                    }
                }
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(gossipManager.dailyUsage < 3 ? .black : .white.opacity(0.7))
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(gossipManager.dailyUsage < 3 ? Color.white : Color.white.opacity(0.1))
                )
            }
            .disabled(gossipManager.dailyUsage >= 3)
            .padding(.horizontal, 24)
        }
    }
}
