//
//  UsageIndicatorView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/03.
//

import Foundation
import SwiftUI

struct UsageIndicatorView: View {
    let isConnected: Bool
    let dailyUsage: Int
    
    var body: some View {
        // 상단: 연결 상태 + 사용량 표시
        HStack {
            // 연결 상태
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            // 사용량 표시
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < dailyUsage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
            
            Text("(\(dailyUsage)/3)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}
