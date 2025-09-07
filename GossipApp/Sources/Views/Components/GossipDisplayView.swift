//
//  GossipDisplayView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/03.
//

import Foundation
import SwiftUI

struct GossipDisplayView: View {
    let currentGossip: String?
    let timeLeft: Int
    
    var body: some View {
        // 중앙: 메시지 표시 영역
        VStack(spacing: 16) {
            if let currentGossip = currentGossip {
                Text(currentGossip)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                CountdownBarView(timeLeft: timeLeft)
            } else {
                VStack(spacing: 12) {
                    Text("😶‍🌫️")
                        .font(.system(size: 48))
                    
                    Text("조용하네요")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("답답한 마음을 적어보세요!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(height: 200)
    }
}
