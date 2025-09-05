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
            config: [.log(false),
                     .compress,
                     .reconnects(true),
                     .reconnectAttempts(5),
                     .reconnectWait(2)
            ]
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
        
        socket?.on(clientEvent: .error) { [weak self] data, _ in
            print("❌ Socket 에러: \(data)")
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
    
    func sendGossip(_ content: String) async throws {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedContent.isEmpty else {
            throw GossipError.emptyContent
        }
        
        guard content.count <= 50 else {
            throw GossipError.contentTooLong
        }
        
        guard dailyUsage < 3 else {
            throw GossipError.dailyLimitReached
        }
        
        guard let url = URL(string: "http://localhost:3000/api/gossip") else {
            throw GossipError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        let body = [
            "content": content,
            "deviceId": deviceId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON 직렬화 오류: \(error)")
            throw GossipError.serializationError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GossipError.invalidResponse
        }
              
        guard (200...299).contains(httpResponse.statusCode) else {
            // 에러 응답 파싱 시도
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print(errorResponse.error)
                throw GossipError.serverError(errorResponse.error)
            }
            throw GossipError.httpError(httpResponse.statusCode)
        }
        
        let responseBody = try JSONDecoder().decode(GossipResponse.self, from: data)
        
        self.dailyUsage = responseBody.userUsage

        print("✅ 뒷담화 전송 완료")
    }
    
    func getUsage() async throws {
        guard let url = URL(string: "http://localhost:3000/api/usage/\(deviceId)") else {
            throw GossipError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GossipError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // 에러 응답 파싱 시도
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print(errorResponse.error)
                throw GossipError.serverError(errorResponse.error)
            }
            
            throw GossipError.httpError(httpResponse.statusCode)
        }
        
        let responseBody = try JSONDecoder().decode(UsageResponse.self, from: data)
        self.dailyUsage = responseBody.usage
        print("✅ usage get 완료")
    }
}

// MARK: - Custom Error Types
enum GossipError: LocalizedError {
    case emptyContent
    case contentTooLong
    case dailyLimitReached
    case invalidURL
    case serializationError
    case invalidResponse
    case networkError
    case httpError(Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "내용을 입력해주세요"
        case .contentTooLong:
            return "50자를 초과할 수 없습니다"
        case .dailyLimitReached:
            return "하루 3번까지만 사용할 수 있습니다"
        case .invalidURL:
            return "잘못된 서버 주소입니다"
        case .serializationError:
            return "데이터 변환 오류"
        case .invalidResponse:
            return "잘못된 서버 응답"
        case .networkError:
            return "네트워크 연결을 확인해주세요"
        case .httpError(let code):
            return "서버 오류 (코드: \(code))"
        case .serverError(let message):
            return message
        }
    }
}
