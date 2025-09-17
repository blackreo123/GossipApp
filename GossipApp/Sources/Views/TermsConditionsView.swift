//
//  TermsConditionsView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/15.
//

import SwiftUI

struct TermsConditionsView: View {
    @Binding var hasAgreedToTerms: Bool
    @State private var hasScrolledToBottom = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더
                VStack(spacing: 16) {
                    Text("📜")
                        .font(.system(size: 60))
                    
                    Text("이용약관 및 커뮤니티 가이드라인")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("안전한 익명 소통을 위해 반드시 확인해주세요")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            termsContent
                            
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                                .onAppear {
                                    withAnimation(.spring()) {
                                        hasScrolledToBottom = true
                                    }
                                }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // 동의 버튼
                Button(action: {
                    if hasScrolledToBottom {
                        withAnimation(.spring()) {
                            hasAgreedToTerms = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: hasScrolledToBottom ? "checkmark.circle.fill" : "scroll.fill")
                        Text(hasScrolledToBottom ? "동의하고 시작하기" : "먼저 내용을 끝까지 읽어주세요")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(hasScrolledToBottom ? .black : .white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(hasScrolledToBottom ? Color.white : Color.white.opacity(0.2))
                    )
                }
                .disabled(!hasScrolledToBottom)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("이용약관 및 커뮤니티 가이드라인")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("최종 수정일: 2025년 9월 15일")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            warningSection
            
            termsSection(
                title: "1. 서비스 이용 연령 제한",
                content: """
                    🔞 본 서비스는 18세 이상만 이용 가능합니다.
                    
                    • 만 18세 미만 사용자의 이용을 금지합니다
                    • 연령 허위 신고 시 서비스 이용이 즉시 중단됩니다
                    • 부모님/보호자의 동의가 있어도 만 18세 미만은 이용할 수 없습니다
                    """
            )
            
            termsSection(
                title: "2. 금지되는 콘텐츠 (무관용 원칙)",
                content: """
                    ❌ 다음 내용은 절대 허용되지 않으며 즉시 제재됩니다:
                    
                    • 욕설, 혐오 표현, 차별적 언어
                    • 성적인 내용, 음란물 관련 언급
                    • 폭력적이거나 위협적인 내용
                    • 타인의 개인정보 노출 시도
                    • 불법 행위 조장 (마약, 도박 등)
                    • 자해, 자살 관련 내용
                    • 스팸, 광고성 게시물
                    • 정치적 선동, 종교적 갈등 조장
                    • 거짓 정보 유포
                    """
            )
            
            termsSection(
                title: "3. 신고 및 차단 시스템",
                content: """
                    🚨 부적절한 내용 발견 시:
                    
                    • 각 메시지 우상단의 '⚠️' 버튼으로 즉시 신고
                    • 신고된 내용은 자동으로 사용자 피드에서 제거
                    • 개발자가 24시간 내 검토 후 조치
                    • 악성 사용자는 영구 차단
                    • 허위 신고 시에도 제재 가능
                    """
            )
            
            termsSection(
                title: "4. 즉시 제재 조치",
                content: """
                    ⚡ 부적절한 콘텐츠 발견 시 즉시:
                    
                    • 해당 메시지 즉시 삭제
                    • 작성자 계정 영구 차단
                    • IP 차단으로 재가입 방지
                    • 필요시 관련 기관에 신고
                    
                    🔒 차단된 사용자는 영구히 서비스 이용 불가
                    """
            )
            
            termsSection(
                title: "5. 사용자 책임",
                content: """
                    📋 모든 사용자는 다음을 준수해야 합니다:
                    
                    • 타인을 존중하는 언어 사용
                    • 건전한 소통 문화 조성에 기여
                    • 부적절한 내용 발견 시 적극적 신고
                    • 익명성을 악용한 괴롭힘 금지
                    • 개인 식별 정보 공개 금지
                    """
            )
            
            termsSection(
                title: "6. 개발자 연락처",
                content: """
                    📧 부적절한 콘텐츠 신고 및 문의:
                    
                    이메일: jihaapp1010@gmail.com
                    
                    ⏰ 신고 접수 후 24시간 내 처리
                    긴급 상황 시 즉시 대응
                    """
            )
            
            termsSection(
                title: "7. 서비스 중단 권리",
                content: """
                    개발자는 다음 경우 사전 통지 없이 서비스를 중단할 수 있습니다:
                    
                    • 대량의 부적절한 콘텐츠 발생 시
                    • 시스템 악용 시도 시
                    • 법적 문제 발생 시
                    • 운영상 필요에 의해
                    """
            )
            
            finalWarning
        }
    }
    
    private var warningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚠️ 중요 안내")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("본 앱은 완전 익명 서비스로, 부적절한 사용 시 영구 차단됩니다. 모든 콘텐츠는 실시간 모니터링되며, 문제 발생 시 즉시 조치됩니다.")
                .font(.body)
                .foregroundColor(.red.opacity(0.9))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    private var finalWarning: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✅ 동의 확인")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("위 내용에 동의하시면 아래 버튼을 눌러 서비스를 시작하세요. 이용약관 위반 시 사전 경고 없이 영구 차단됩니다.")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(.bottom, 8)
    }
}
