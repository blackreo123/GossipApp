import Foundation
import SocketIO
import SwiftUI

@MainActor
class GossipManager: ObservableObject {
    @Published var currentGossip: String?
    @Published var currentGossipDeviceId: String? // 메시지 작성자 ID 추가
    @Published var timeLeft: Int = 0
    @Published var dailyUsage: Int = 0
    @Published var isConnected: Bool = false
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var deviceId: String
    private let contentFilter = ContentFilterService()
    
    // 로컬 필터링
    @Published var hiddenMessages: Set<String> = []
    @Published var blockedUsers: Set<String> = []
    
    init() {
        self.deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "deviceId")
            return newId
        }()
        
        loadLocalFilters()
        setupSocket()
        setupNotificationObservers()
    }
    
    private var serverURL: String {
    #if DEBUG
        return "http://localhost:3000"
    #else
        return "https://gossip-server-production.up.railway.app"
    #endif
    }
    
    private func setupSocket() {
        guard let url = URL(string: serverURL) else {
            print("잘못된 서버 URL: \(serverURL)")
            return
        }
        
        manager = SocketManager(
            socketURL: url,
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
            print("서버 연결됨")
            self?.isConnected = true
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            print("서버 연결 해제")
            self?.isConnected = false
        }
        
        socket?.on(clientEvent: .error) { [weak self] data, _ in
            print("Socket 에러: \(data)")
            self?.isConnected = false
        }
        
        // 뒷담화 표시 이벤트 (deviceId 포함)
        socket?.on("gossip-display") { [weak self] data, _ in
            guard let responseData = data[0] as? [String: Any] else { return }
            
            if let gossipData = responseData["gossip"] as? [String: Any],
               let content = gossipData["content"] as? String,
               let messageDeviceId = gossipData["deviceId"] as? String {
                
                // 로컬 필터링 적용
                if !(self?.shouldHideMessage(content, deviceId: messageDeviceId) ?? false) {
                    self?.currentGossip = content
                    self?.currentGossipDeviceId = messageDeviceId
                    self?.timeLeft = 5
                } else {
                    // 필터링된 메시지는 표시하지 않음
                    self?.currentGossip = nil
                    self?.currentGossipDeviceId = nil
                    self?.timeLeft = 0
                }
            } else {
                self?.currentGossip = nil
                self?.currentGossipDeviceId = nil
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
                self?.currentGossipDeviceId = nil
            }
        }
    }
    
    // MARK: - 로컬 필터링
    
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
        let hiddenArray = UserDefaults.standard.array(forKey: "hiddenMessages") as? [String] ?? []
        hiddenMessages = Set(hiddenArray)
        
        let blockedArray = UserDefaults.standard.array(forKey: "blockedUsers") as? [String] ?? []
        blockedUsers = Set(blockedArray)
    }
    
    /// 알림 옵저버 설정
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .hideMessageLocally,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let messageContent = notification.userInfo?["messageContent"] as? String {
                self?.hiddenMessages.insert(messageContent)
                
                // 현재 표시 중인 메시지가 숨겨진 메시지라면 즉시 제거
                if self?.currentGossip == messageContent {
                    self?.currentGossip = nil
                    self?.currentGossipDeviceId = nil
                    self?.timeLeft = 0
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .blockUserLocally,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let deviceId = notification.userInfo?["deviceId"] as? String {
                self?.blockedUsers.insert(deviceId)
                
                // 현재 표시 중인 메시지가 차단된 사용자의 것이라면 즉시 제거
                if self?.currentGossipDeviceId == deviceId {
                    self?.currentGossip = nil
                    self?.currentGossipDeviceId = nil
                    self?.timeLeft = 0
                }
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
        
        // 기본 유효성 검사
        guard !trimmedContent.isEmpty else {
            throw GossipError.emptyContent
        }
        
        guard trimmedContent.count <= 50 else {
            throw GossipError.contentTooLong
        }
        
        // 클라이언트 사이드 필터링 (기존 방식)
        let filteredContent = await contentFilter.filterContent(trimmedContent)
        
        try await sendToServer(filteredContent)
    }
    
    private func sendToServer(_ content: String) async throws {
        guard !content.isEmpty else {
            throw GossipError.emptyContent
        }
        
        guard content.count <= 50 else {
            throw GossipError.contentTooLong
        }
        
        guard dailyUsage < 3 else {
            throw GossipError.dailyLimitReached
        }
        
        guard let url = URL(string: "\(serverURL)/api/gossip") else {
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
            print("JSON 직렬화 오류: \(error)")
            throw GossipError.serializationError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GossipError.invalidResponse
        }
        
        // 403 Forbidden (차단된 사용자)
        if httpResponse.statusCode == 403 {
            throw GossipError.userBanned
        }
              
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print(errorResponse.error)
                throw GossipError.serverError(errorResponse.error)
            }
            throw GossipError.httpError(httpResponse.statusCode)
        }
        
        let responseBody = try JSONDecoder().decode(GossipResponse.self, from: data)
        
        self.dailyUsage = responseBody.userUsage

        print("뒷담화 전송 완료")
    }
    
    func getUsage() async throws {
        guard let url = URL(string: "\(serverURL)/api/usage/\(deviceId)") else {
            throw GossipError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GossipError.invalidResponse
        }
        
        if httpResponse.statusCode == 403 {
            throw GossipError.userBanned
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print(errorResponse.error)
                throw GossipError.serverError(errorResponse.error)
            }
            
            throw GossipError.httpError(httpResponse.statusCode)
        }
        
        let responseBody = try JSONDecoder().decode(UsageResponse.self, from: data)
        self.dailyUsage = responseBody.usage
        print("usage get 완료")
    }
}

// MARK: - Custom Error Types (기존과 동일)
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
    case userBanned
    case contentFiltered(String)
    
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
        case .userBanned:
            return "이용이 제한된 사용자입니다"
        case .contentFiltered(let reason):
            return reason
        }
    }
}
