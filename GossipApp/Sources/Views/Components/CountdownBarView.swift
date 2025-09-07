//
//  CountdownBarView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/03.
//

import Foundation
import SwiftUI

struct CountdownBarView: View {
    let timeLeft: Int
    let totalTime: Int = 5
    @State private var animatedProgress: Double = 1.0
    
    private var targetProgress: Double {
        timeLeft > 0 ? Double(timeLeft) / Double(totalTime) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경 바
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                    
                    // 진행률 바
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * animatedProgress, height: 4)
                        .animation(.linear(duration: 0.95), value: animatedProgress)
                }
            }
            .frame(height: 4)
            
            // 시간 표시
            if timeLeft > 0 {
                Text("\(timeLeft)초")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 32)
        .opacity(timeLeft > 0 ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.3), value: timeLeft > 0)
        .onChange(of: timeLeft) { _, newValue in
            withAnimation(.linear(duration: 0.95)) {
                animatedProgress = targetProgress
            }
        }
        .onAppear {
            animatedProgress = targetProgress
        }
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            CountdownBarView(timeLeft: 5)
            CountdownBarView(timeLeft: 3)
            CountdownBarView(timeLeft: 1)
            CountdownBarView(timeLeft: 0)
        }
    }
}
