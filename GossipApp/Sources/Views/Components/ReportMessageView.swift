import SwiftUI

struct ReportMessageView: View {
    let messageContent: String
    let messageDeviceId: String? // 메시지 작성자 ID 추가
    @Binding var isPresented: Bool
    @StateObject private var reportManager = ReportManager()
    @StateObject private var toastManager = ToastManager()
    
    @State private var selectedReason: ReportReason = .inappropriate
    @State private var additionalComment = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false
    @State private var willBlockUser = false
    @State private var willHideMessage = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        messageConfirmationSection
                        reasonSelectionSection
                        actionOptionsSection
                        additionalCommentSection
                        submitButtonSection
                        contactSection
                    }
                    .padding()
                }
            }
            .navigationTitle("메시지 신고")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .toast(toastManager)
        .alert("신고 완료", isPresented: $showConfirmation) {
            Button("확인") {
                isPresented = false
            }
        } message: {
            Text("신고가 접수되었습니다. 24시간 내 검토 후 조치됩니다.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("부적절한 콘텐츠 신고")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("건전한 커뮤니티를 위해 신중하게 신고해주세요")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    private var messageConfirmationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🚨 다음 메시지를 신고하시겠습니까?")
                .font(.headline)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("신고할 메시지:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(messageContent)")
                    .font(.body)
                    .foregroundColor(.white)
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.red.opacity(0.4), lineWidth: 1)
                            )
                    )
            }
            
            Text("⏰ 메시지는 5초 후 자동으로 사라지지만, 신고는 접수되어 검토됩니다.")
                .font(.caption)
                .foregroundColor(.orange.opacity(0.8))
                .padding(.top, 4)
        }
    }
    
    private var reasonSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("신고 사유 선택")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ReportReason.allCases, id: \.self) { reason in
                    reasonButton(reason)
                }
            }
        }
    }
    
    private func reasonButton(_ reason: ReportReason) -> some View {
        Button(action: {
            selectedReason = reason
            withAnimation(.spring(response: 0.3)) {}
        }) {
            VStack(spacing: 8) {
                Image(systemName: reason.icon)
                    .font(.system(size: 18))
                    .foregroundColor(selectedReason == reason ? .black : reason.color)
                
                Text(reason.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedReason == reason ? .black : .white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedReason == reason ? reason.color : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        selectedReason == reason ? Color.clear : reason.color.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .scaleEffect(selectedReason == reason ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: selectedReason)
    }
    
    // 새로 추가: 액션 옵션 섹션
    private var actionOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("추가 조치")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // 메시지 숨김 옵션
                HStack {
                    Button(action: {
                        willHideMessage.toggle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: willHideMessage ? "checkmark.square.fill" : "square")
                                .foregroundColor(willHideMessage ? .blue : .white.opacity(0.6))
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("이 메시지 숨기기")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                
                                Text("내 화면에서 즉시 제거됩니다")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // 사용자 차단 옵션
                if messageDeviceId != nil {
                    HStack {
                        Button(action: {
                            willBlockUser.toggle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: willBlockUser ? "checkmark.square.fill" : "square")
                                    .foregroundColor(willBlockUser ? .red : .white.opacity(0.6))
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("이 사용자 차단")
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                    
                                    Text("향후 이 사용자의 모든 메시지가 숨겨집니다")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var additionalCommentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("추가 설명 (선택사항)")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("더 자세한 내용이 있다면 적어주세요...", text: $additionalComment, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .lineLimit(3...6)
        }
    }
    
    private var submitButtonSection: some View {
        Button(action: submitReport) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.black)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text(isSubmitting ? "신고 접수 중..." : "신고 제출")
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
        .disabled(isSubmitting)
        .opacity(isSubmitting ? 0.7 : 1.0)
    }
    
    private var contactSection: some View {
        VStack(spacing: 8) {
            Text("문의가 있으시면 연락해주세요")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("📧 jihaapp1010@gmail.com")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .fontWeight(.medium)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Actions
    
    private func submitReport() {
        Task {
            isSubmitting = true
            defer { isSubmitting = false }
            
            // 1. 선택된 액션들 즉시 실행
            if willHideMessage {
                hideMessageLocally()
            }
            
            if willBlockUser, let deviceId = messageDeviceId {
                blockUserLocally(deviceId)
            }
            
            // 2. 서버에 신고 제출
            let result = await reportManager.reportMessage(messageContent, reason: selectedReason)
            
            switch result {
            case .success:
                showConfirmation = true
            case .dailyLimitReached:
                toastManager.showError("하루 신고 한도를 초과했습니다")
            case .networkError:
                toastManager.showError("네트워크 오류가 발생했습니다")
            case .serverError(let code):
                toastManager.showError("서버 오류: \(code)")
            case .alreadyProcessing:
                toastManager.showInfo("이미 처리 중입니다")
            }
        }
    }
    
    private func hideMessageLocally() {
        // 로컬에서 메시지 숨김
        var hiddenMessages = Set(UserDefaults.standard.array(forKey: "hiddenMessages") as? [String] ?? [])
        hiddenMessages.insert(messageContent)
        UserDefaults.standard.set(Array(hiddenMessages), forKey: "hiddenMessages")
        
        // 알림 발송
        NotificationCenter.default.post(
            name: .hideMessageLocally,
            object: nil,
            userInfo: ["messageContent": messageContent]
        )
        
        toastManager.showSuccess("메시지가 숨겨졌습니다")
    }
    
    private func blockUserLocally(_ deviceId: String) {
        // 로컬에서 사용자 차단
        var blockedUsers = Set(UserDefaults.standard.array(forKey: "blockedUsers") as? [String] ?? [])
        blockedUsers.insert(deviceId)
        UserDefaults.standard.set(Array(blockedUsers), forKey: "blockedUsers")
        
        // 알림 발송
        NotificationCenter.default.post(
            name: .blockUserLocally,
            object: nil,
            userInfo: ["deviceId": deviceId]
        )
        
        toastManager.showSuccess("사용자가 차단되었습니다")
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let hideMessageLocally = Notification.Name("hideMessageLocally")
    static let blockUserLocally = Notification.Name("blockUserLocally")
}

#Preview {
    @Previewable @State var isPresented = true
    
    ReportMessageView(
        messageContent: "이것은 테스트 메시지입니다",
        messageDeviceId: "test-device-id",
        isPresented: $isPresented
    )
}
