import SwiftUI

struct GossipView: View {
    @StateObject private var gossipManager = GossipManager()
    @StateObject private var toastManager = ToastManager()
    @State private var isComposing = false
    @State private var newMessage = ""
    
    var body: some View {
        ZStack {
            // 배경
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                UsageIndicatorView(isConnected: gossipManager.isConnected, dailyUsage: gossipManager.dailyUsage)
                
                Spacer()
                
                // 업데이트된 파라미터 전달
                GossipDisplayView(
                    currentGossip: gossipManager.currentGossip,
                    currentGossipDeviceId: gossipManager.currentGossipDeviceId, // 새로 추가
                    timeLeft: gossipManager.timeLeft
                )
                
                Spacer()
                
                ComposeButtonView(gossipManager: gossipManager, toastManager: toastManager, isComposing: $isComposing, newMessage: $newMessage)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .toast(toastManager)
        .onAppear {
            gossipManager.connect()
            
            Task {
                do {
                    try await gossipManager.getUsage()
                } catch let error as GossipError {
                    toastManager.show(error.toastMessage)
                } catch {
                    toastManager.showError("알 수 없는 오류가 발생했습니다.")
                }
            }
        }
        .onDisappear {
            gossipManager.disconnect()
        }
        .onChange(of: gossipManager.isConnected) { oldValue, newValue in
            switch (oldValue, newValue) {
            case (false, true):
                toastManager.showSuccess("서버에 연결되었습니다!")
            case (true, false):
                toastManager.showError("연결이 끊어졌습니다")
            default:
                break
            }
        }
    }
}

#Preview {
    GossipView()
}
