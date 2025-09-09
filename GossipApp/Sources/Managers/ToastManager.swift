//
//  ToastManager.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/08.
//

import Foundation
import SwiftUI

@MainActor
class ToastManager: ObservableObject {
    @Published var currentToast: ToastMessage?
    @Published var isShowing = false
    
    private var workItem: DispatchWorkItem?
    
    func show(_ message: ToastMessage) {
        // 기존 토스트가 있다면 취소
        workItem?.cancel()
        
        // 새 토스트 설정
        currentToast = message
        
        withAnimation {
            isShowing = true
        }
        
        // 자동 숨김 설정
        workItem = DispatchWorkItem { [weak self] in
            withAnimation {
                self?.isShowing = false
            }
            
            // 애니메이션 완료 후 토스트 제거
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.currentToast = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + message.duration, execute: workItem!)
    }
    
    func hide() {
        workItem?.cancel()
        withAnimation {
            isShowing = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.currentToast = nil
        }
    }
    
    func showSuccess(_ text: String, duration: TimeInterval = 2.0) {
        show(ToastMessage(text, type: .success, duration: duration))
    }
    
    func showError(_ text: String, duration: TimeInterval = 3.0) {
        show(ToastMessage(text, type: .error, duration: duration))
    }
    
    func showInfo(_ text: String, duration: TimeInterval = 2.5) {
        show(ToastMessage(text, type: .info, duration: duration))
    }
}
