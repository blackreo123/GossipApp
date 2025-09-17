//
//  PrivacyPolicyOnboardingView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/09.
//

import Foundation
import SwiftUI

struct PrivacyPolicyOnboardingView: View {
    @Binding var hasAgreed: Bool
    @State private var hasScrolledToBottom = false
    
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
                // 헤더
                VStack(spacing: 16) {
                    Text("🔒")
                        .font(.system(size: 60))
                    
                    Text("개인정보 처리방침")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("안전한 개인정보 보호를 위해 확인해주세요")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            privacyPolicyContent
                            
                            // 스크롤 끝 감지용 투명 뷰
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
                            hasAgreed = true
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
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("개인정보 처리방침")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("최종 수정일: 2025년 9월 15일")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            privacySection(
                title: "1. 수집하는 개인정보",
                content: """
                    저희는 완전한 익명성을 보장하기 위해 최소한의 정보만 수집합니다:
                    
                    • 디바이스 식별자 (UUID, 완전 익명)
                    • 일일 사용량 (하루 3회 제한 관리용)
                    • 앱 사용 통계 (익명)
                    
                    ⚠️ 개인을 식별할 수 있는 어떠한 정보도 수집하지 않습니다.
                    """
            )
            
            privacySection(
                title: "2. 개인정보 처리 목적",
                content: """
                    수집된 정보는 다음 용도로만 사용됩니다:
                    
                    • 서비스 제공 및 운영
                    • 하루 3회 사용 제한 관리
                    • 서비스 품질 개선
                    • 부정 사용 방지
                    """
            )
            
            privacySection(
                title: "3. 개인정보 보관 및 삭제",
                content: """
                    완전한 데이터 보호를 위해:
                    
                    • 모든 메시지는 5초 후 자동 완전 삭제
                    • 사용량 정보는 매일 자정에 자동 초기화
                    • 서버에 개인정보가 저장되지 않음
                    • 앱 삭제 시 모든 데이터 완전 제거
                    """
            )
            
            privacySection(
                title: "4. 제3자 제공",
                content: """
                    저희는 수집된 정보를 제3자에게 제공하지 않습니다.
                    
                    • 광고 회사에 정보 제공 안 함
                    • 분석 업체에 개인정보 제공 안 함  
                    • 정부 기관 요청 시에도 제공할 개인정보 없음
                    """
            )
            
            privacySection(
                title: "5. 사용자 권리",
                content: """
                    사용자는 다음 권리를 가집니다:
                    
                    • 언제든지 앱 삭제 가능
                    • 개인정보 처리 거부 권리
                    • 문의 및 불만 제기 권리
                    """
            )
            
            privacySection(
                title: "6. 보안 조치",
                content: """
                    사용자 데이터의 보안을 위해 다음과 같은 조치를 취합니다:
                    
                    • HTTPS 통신으로 데이터 암호화
                    • 서버에 개인정보 미저장
                    • 정기적인 보안 점검
                    • 최신 보안 업데이트 적용
                    """
            )
            
            privacySection(
                title: "7. 쿠키 및 유사 기술",
                content: """
                    본 앱은 웹이 아닌 네이티브 앱이므로 쿠키를 사용하지 않습니다.
                    
                    • 웹뷰 사용 안 함
                    • 추적 기술 사용 안 함
                    • 광고 식별자 수집 안 함
                    """
            )
            
            privacySection(
                title: "8. 연락처",
                content: """
                    개인정보 관련 문의사항이 있으시면 언제든지 연락해주세요:
                    
                    📧 이메일: jihaapp1010@gmail.com
                    
                    모든 문의사항에 대해 빠르게 응답드리겠습니다.
                    """
            )
            
            privacySection(
                title: "9. 정책 변경",
                content: """
                    개인정보처리방침이 변경되는 경우, 앱 업데이트를 통해 알려드립니다.
                    
                    중요한 변경사항이 있는 경우, 앱 실행 시 다시 동의를 받습니다.
                    """
            )
            
            privacySection(
                title: "10. 법적 근거",
                content: """
                    본 개인정보처리방침은 대한민국 개인정보보호법을 준수합니다.
                    
                    • 개인정보 최소 수집 원칙 준수
                    • 목적 외 사용 금지
                    • 안전한 관리 조치 이행
                    """
            )
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
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
