import SwiftUI

struct ContentView: View {
    @StateObject private var gossipManager = GossipManager()
    @State private var isComposing = false
    @State private var newMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
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
                    
                    GossipDisplayView(currentGossip: gossipManager.currentGossip, timeLeft: gossipManager.timeLeft)
                    
                    Spacer()
                    
                    ComposeButtonView(gossipManager: gossipManager, isComposing: $isComposing, newMessage: $newMessage)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .onAppear {
            gossipManager.connect()
            
            // 연결 후 사용량 가져오기
            Task {
                try? await gossipManager.getUsage()
            }
        }
        .onDisappear {
            gossipManager.disconnect()
        }
    }
}

#Preview {
    ContentView()
}
