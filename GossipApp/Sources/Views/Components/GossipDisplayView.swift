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
    @State private var showingReportAlert = false
    @State private var showingReportConfirmation = false
    
    var body: some View {
        VStack(spacing: 16) {
            if let currentGossip = currentGossip {
                // 메시지 영역
                ZStack(alignment: .topTrailing) {
                    // 메시지 텍스트
                    Text(currentGossip)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40) // 신고 버튼 공간 확보
                        .padding(.vertical, 16)
                    
                    // 신고 버튼
                    Button(action: {
                        showingReportAlert = true
                    }) {
                        Image(systemName: "light.beacon.max.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red.opacity(0.8))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 28, height: 28)
                            )
                    }
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity)
                
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
        .alert("이 메시지를 신고하시겠습니까?", isPresented: $showingReportAlert) {
            Button("취소", role: .cancel) { }
            Button("신고", role: .destructive) {
                // 로그만 남기고 끝
                print("📋 신고됨: \(currentGossip ?? "")")
                showingReportConfirmation = true
            }
        } message: {
            Text("부적절한 내용으로 판단되면 검토 후 조치됩니다.")
        }
        .alert("신고 완료", isPresented: $showingReportConfirmation) {
            Button("확인") { }
        } message: {
            Text("신고해주셔서 감사합니다.")
        }
    }
}
