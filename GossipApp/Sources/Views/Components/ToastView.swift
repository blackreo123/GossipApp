//
//  ToastView.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/07.
//

import Foundation
import SwiftUI

struct ToastView: View {
    let message: ToastMessage
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: message.type.icon)
                .foregroundColor(message.type.color)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message.text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(message.type.color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(isShowing ? 1.0 : 0.8)
        .opacity(isShowing ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
}

#Preview {
    @Previewable @State var isShowing: Bool = true
    ToastView(message: .init("Hello, World!", type: .success), isShowing: $isShowing)
    ToastView(message: .init("Hello, World!", type: .error), isShowing: $isShowing)
    ToastView(message: .init("Hello, World!", type: .info), isShowing: $isShowing)
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    if let toast = toastManager.currentToast {
                        ToastView(message: toast, isShowing: $toastManager.isShowing)
                            .padding(.horizontal, 20)
                            .padding(.top, 60)
                    }
                    
                    Spacer()
                }
                .allowsHitTesting(false) // 터치 이벤트 통과
                , alignment: .top
            )
    }
}
