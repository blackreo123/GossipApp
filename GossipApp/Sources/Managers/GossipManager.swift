import Foundation
import SocketIO
import SwiftUI

@MainActor
class GossipManager: ObservableObject {
    @Published var currentGossip: String?
    @Published var timeLeft: Int = 0
    @Published var dailyUsage: Int = 0
    @Published var isConnected: Bool = false
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var deviceId: String
    
    init() {
        self.deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "deviceId")
            return newId
        }()
        
        setupSocket()
    }
    
    private func setupSocket() {
        manager = SocketManager(
            socketURL: URL(string: "http://localhost:3000")!,
            config: [.log(false), .compress]
        )
        socket = manager?.defaultSocket
        
        // 연결 이벤트
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            print("🔗 서버 연결됨")
            self?.isConnected = true
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            print("🔌 서버 연결 해제")
            self?.isConnected = false
        }
        
        // 뒷담화 표시 이벤트
        socket?.on("gossip-display") { [weak self] data, _ in
            guard let responseData = data[0] as? [String: Any] else { return }
            
            if let gossipData = responseData["gossip"] as? [String: Any],
               let content = gossipData["content"] as? String {
                self?.currentGossip = content
                self?.timeLeft = 5
            } else {
                self?.currentGossip = nil
                self?.timeLeft = 0
            }
        }
        
        // 카운트다운 이벤트
        socket?.on("countdown") { [weak self] data, _ in
            guard let responseData = data[0] as? [String: Any],
                  let timeLeft = responseData["timeLeft"] as? Int else { return }
            
            self?.timeLeft = timeLeft
            
            if timeLeft <= 0 {
                self?.currentGossip = nil
            }
        }
    }
    
    func connect() {
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    func sendGossip(_ content: String) {
        let url = URL(string: "http://localhost:3000/api/gossip")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "content": content,
            "deviceId": deviceId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON 직렬화 오류: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ 전송 오류: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self?.dailyUsage += 1
                print("✅ 뒷담화 전송 완료")
            }
        }.resume()
    }
}
