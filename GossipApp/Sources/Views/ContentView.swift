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
                    
                    // 하단: 작성 버튼 또는 입력창
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
                                            try await gossipManager.sendGossip(newMessage)
                                            isComposing = false
                                            newMessage = ""
                                        } catch {
                                            print("에러어어: \(error)")
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
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .onAppear {
            gossipManager.connect()
        }
        .onDisappear {
            gossipManager.disconnect()
        }
    }
}

#Preview {
    ContentView()
}
