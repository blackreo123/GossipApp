import Foundation
import SwiftUI

@MainActor
class ReportManager: ObservableObject {
    @Published var isReporting = false
    @Published var reportHistory: [ReportRecord] = []
    
    private let maxReportsPerDay = 10 // 하루 최대 신고 횟수
    
    init() {
        loadReportHistory()
    }
    
    /// 메시지 신고 (5초 컨셉에 맞춘 버전)
    func reportMessage(_ content: String, reason: ReportReason) async -> ReportResult {
        guard !isReporting else { return .alreadyProcessing }
        
        // 일일 신고 제한 체크
        let todayReports = getTodayReports()
        if todayReports.count >= maxReportsPerDay {
            return .dailyLimitReached
        }
        
        isReporting = true
        defer { isReporting = false }
        
        do {
            // 서버에 신고 전송
            let result = try await sendReportToServer(content: content, reason: reason)
            
            // 로컬에 신고 기록 저장
            let record = ReportRecord(
                id: UUID(),
                content: content,
                reason: reason,
                timestamp: Date(),
                status: .submitted
            )
            
            reportHistory.append(record)
            saveReportHistory()
            
            return result
            
        } catch {
            print("❌ 신고 전송 실패: \(error)")
            return .networkError
        }
    }
    
    /// 서버에 신고 전송
    private func sendReportToServer(content: String, reason: ReportReason) async throws -> ReportResult {
        guard let url = URL(string: "\(getServerURL())/api/report") else {
            throw ReportError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        let reportData = ReportData(
            content: content,
            reason: reason.rawValue,
            timestamp: Date().timeIntervalSince1970,
            deviceId: getDeviceId(),
            appVersion: getAppVersion()
        )
        
        request.httpBody = try JSONEncoder().encode(reportData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReportError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            print("✅ 신고 접수 완료: \(content)")
            return .success
        } else {
            throw ReportError.serverError(httpResponse.statusCode)
        }
    }
    
    /// 개발자 이메일 연락 (간단한 버전)
    func contactDeveloper(message: String) {
        let email = "jihaapp1010@gmail.com"
        let subject = "[임귀당귀] 신고 관련 문의"
        let body = """
        앱 버전: \(getAppVersion())
        문의 내용: \(message)
        문의 시간: \(Date())
        
        ----
        이 이메일은 임귀당귀 앱에서 생성되었습니다.
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(forURLQueryValue: true) ?? "")&body=\(body.addingPercentEncoding(forURLQueryValue: true) ?? "")") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    /// 오늘 신고 목록
    private func getTodayReports() -> [ReportRecord] {
        let calendar = Calendar.current
        return reportHistory.filter { calendar.isDateInToday($0.timestamp) }
    }
    
    /// 신고 기록 저장
    private func saveReportHistory() {
        if let encoded = try? JSONEncoder().encode(reportHistory) {
            UserDefaults.standard.set(encoded, forKey: "reportHistory")
        }
    }
    
    /// 신고 기록 로드
    func loadReportHistory() {
        if let data = UserDefaults.standard.data(forKey: "reportHistory"),
           let decoded = try? JSONDecoder().decode([ReportRecord].self, from: data) {
            reportHistory = decoded
            
            // 7일 이상 된 기록 자동 정리
            cleanupOldReports()
        }
    }
    
    /// 오래된 신고 기록 정리 (7일)
    private func cleanupOldReports() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        reportHistory = reportHistory.filter { $0.timestamp > weekAgo }
        saveReportHistory()
    }
    
    // MARK: - Helper Methods
    
    private func getServerURL() -> String {
        #if DEBUG
        return "http://localhost:3000"
        #else
        return "https://gossip-server-production.up.railway.app"
        #endif
    }
    
    private func getDeviceId() -> String {
        return UserDefaults.standard.string(forKey: "deviceId") ?? UUID().uuidString
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Data Models

struct ReportData: Codable {
    let content: String
    let reason: String
    let timestamp: TimeInterval
    let deviceId: String
    let appVersion: String
}

struct ReportRecord: Codable, Identifiable {
    let id: UUID
    let content: String
    let reason: ReportReason
    let timestamp: Date
    let status: ReportStatus
}

enum ReportReason: String, CaseIterable, Codable {
    case inappropriate = "부적절한 내용"
    case spam = "스팸/광고"
    case harassment = "괴롭힘/혐오"
    case personalInfo = "개인정보 노출"
    case violence = "폭력적 내용"
    case sexual = "성적인 내용"
    case illegal = "불법 행위"
    case other = "기타"
    
    var icon: String {
        switch self {
        case .inappropriate: return "exclamationmark.triangle.fill"
        case .spam: return "envelope.badge.fill"
        case .harassment: return "person.fill.xmark"
        case .personalInfo: return "lock.fill"
        case .violence: return "hand.raised.fill"
        case .sexual: return "eye.slash.fill"
        case .illegal: return "exclamationmark.octagon.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .inappropriate: return .orange
        case .spam: return .yellow
        case .harassment: return .red
        case .personalInfo: return .purple
        case .violence: return .red
        case .sexual: return .pink
        case .illegal: return .red
        case .other: return .gray
        }
    }
}

enum ReportStatus: String, Codable {
    case submitted = "접수됨"
    case processing = "처리중"
    case resolved = "해결됨"
    case rejected = "반려됨"
}

enum ReportResult {
    case success
    case alreadyProcessing
    case dailyLimitReached
    case networkError
    case serverError(Int)
    
    var message: String {
        switch self {
        case .success:
            return "신고가 접수되었습니다. 24시간 내 검토됩니다."
        case .alreadyProcessing:
            return "이미 신고 처리 중입니다."
        case .dailyLimitReached:
            return "하루 신고 한도를 초과했습니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        }
    }
}

enum ReportError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
}

// MARK: - String Extension

extension String {
    func addingPercentEncoding(forURLQueryValue: Bool) -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
