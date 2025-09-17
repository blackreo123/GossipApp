import Foundation
import SwiftUI

struct GossipDisplayView: View {
    let currentGossip: String?
    let timeLeft: Int
    @State private var showingReportSheet = false
    @State private var reportingMessage: String = "" // 신고할 메시지 별도 저장
    
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
                    
                    // 강화된 신고 버튼
                    Button(action: {
                        reportingMessage = currentGossip // 현재 메시지를 별도 저장
                        showingReportSheet = true
                    }) {
                        Image(systemName: "exclamationmark.triangle.fill")
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
                    
                    VStack(spacing: 4) {
                        Text("답답한 마음을 털어놓아 보세요")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("🔞 18세 이상 전용")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.7))
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .frame(height: 200)
        // 중요: sheet를 VStack 밖으로 이동하여 5초 타이머와 독립
        .sheet(isPresented: $showingReportSheet) {
            ReportMessageView(
                messageContent: reportingMessage, // 별도 저장된 메시지 사용
                isPresented: $showingReportSheet
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GossipDisplayView(
            currentGossip: "이것은 테스트 메시지입니다",
            timeLeft: 3
        )
        
        GossipDisplayView(
            currentGossip: nil,
            timeLeft: 0
        )
    }
    .background(Color.black)
}
