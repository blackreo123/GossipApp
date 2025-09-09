//
//  ToastMessage.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/07.
//

import Foundation
import SwiftUI

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: ToastType
    let duration: TimeInterval
    
    enum ToastType {
        case success
        case error
        case info
        
        var color: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            case .info:
                return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "exclamationmark.circle.fill"
            case .info:
                return "info.circle.fill"
            }
        }
    }
    
    init(_ text: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        self.text = text
        self.type = type
        self.duration = duration
    }
}
