import SwiftUI

struct ContentView: View {
    @State private var currentMessage = "😶‍🌫️ 조용하네요"
    @State private var timeLeft = 0
    @State private var dailyUsage = 0
    
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
                    // 상단: 사용량 표시
                    HStack {
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
                    
                    Spacer()
                    
                    // 중앙: 메시지 표시 영역
                    VStack(spacing: 16) {
                        Text(currentMessage)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        if timeLeft > 0 {
                            Text("\(timeLeft)초")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(height: 200)
                    
                    Spacer()
                    
                    // 하단: 작성 버튼
                    Button(action: {
                        // 테스트용 메시지
                        currentMessage = "안녕하세요! 테스트 메시지입니다 ✨"
                        dailyUsage = min(dailyUsage + 1, 3)
                        
                        // 5초 카운트다운 시뮬레이션
                        timeLeft = 5
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                            timeLeft -= 1
                            if timeLeft <= 0 {
                                timer.invalidate()
                                currentMessage = "😶‍🌫️ 조용하네요"
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if dailyUsage < 3 {
                                Image(systemName: "plus")
                                Text("뒷담화")
                            } else {
                                Text("내일 또 만나요")
                            }
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(dailyUsage < 3 ? .black : .white.opacity(0.7))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(dailyUsage < 3 ? Color.white : Color.white.opacity(0.1))
                        )
                    }
                    .disabled(dailyUsage >= 3)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
