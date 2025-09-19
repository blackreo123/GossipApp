import Foundation
import SwiftUI

struct GossipDisplayView: View {
    let currentGossip: String?
    let currentGossipDeviceId: String? // 메시지 작성자 ID 추가
    let timeLeft: Int
    @State private var showingReportSheet = false
    @State private var reportingMessage: String = ""
    @State private var reportingDeviceId: String? = nil
    
    // 로컬 필터링을 위한 상태
    @State private var hiddenMessages: Set<String> = []
    @State private var blockedUsers: Set<String> = []
    
    var body: some View {
        VStack(spacing: 16) {
            if let currentGossip = currentGossip,
               let deviceId = currentGossipDeviceId,
               !shouldHideMessage(currentGossip, deviceId: deviceId) {
                
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
                    
                    // 신고 버튼 (자기 메시지가 아닐 때만 표시)
                    if !isMyMessage(deviceId) {
                        Button(action: {
                            reportingMessage = currentGossip
                            reportingDeviceId = deviceId
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
        .onAppear {
            loadLocalFilters()
            setupNotificationObservers()
        }
        .sheet(isPresented: $showingReportSheet) {
            ReportMessageView(
                messageContent: reportingMessage,
                messageDeviceId: reportingDeviceId,
                isPresented: $showingReportSheet
            )
        }
    }
    
    // MARK: - Helper Methods
    
    /// 자기가 작성한 메시지인지 확인
    private func isMyMessage(_ messageDeviceId: String) -> Bool {
        let myDeviceId = UserDefaults.standard.string(forKey: "deviceId") ?? ""
        return messageDeviceId == myDeviceId
    }
    
    /// 메시지를 숨겨야 하는지 판단
    private func shouldHideMessage(_ content: String, deviceId: String) -> Bool {
        // 1. 숨겨진 메시지인지 확인
        if hiddenMessages.contains(content) {
            return true
        }
        
        // 2. 차단된 사용자의 메시지인지 확인
        if blockedUsers.contains(deviceId) {
            return true
        }
        
        return false
    }
    
    /// 로컬 필터 데이터 로드
    private func loadLocalFilters() {
        // 숨겨진 메시지 로드
        let hiddenArray = UserDefaults.standard.array(forKey: "hiddenMessages") as? [String] ?? []
        hiddenMessages = Set(hiddenArray)
        
        // 차단된 사용자 로드
        let blockedArray = UserDefaults.standard.array(forKey: "blockedUsers") as? [String] ?? []
        blockedUsers = Set(blockedArray)
    }
    
    /// 알림 옵저버 설정
    private func setupNotificationObservers() {
        // 메시지 숨김 알림
        NotificationCenter.default.addObserver(
            forName: .hideMessageLocally,
            object: nil,
            queue: .main
        ) { notification in
            if let messageContent = notification.userInfo?["messageContent"] as? String {
                hiddenMessages.insert(messageContent)
            }
        }
        
        // 사용자 차단 알림
        NotificationCenter.default.addObserver(
            forName: .blockUserLocally,
            object: nil,
            queue: .main
        ) { notification in
            if let deviceId = notification.userInfo?["deviceId"] as? String {
                blockedUsers.insert(deviceId)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GossipDisplayView(
            currentGossip: "이것은 테스트 메시지입니다",
            currentGossipDeviceId: "test-device-id",
            timeLeft: 3
        )
        
        GossipDisplayView(
            currentGossip: nil,
            currentGossipDeviceId: nil,
            timeLeft: 0
        )
    }
    .background(Color.black)
}
