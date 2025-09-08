//
//  GossipError+Extention.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/08.
//

import Foundation
import SwiftUI

extension GossipError {
    var toastMessage: ToastMessage {
        switch self {
        case .emptyContent:
            return ToastMessage("내용을 입력해주세요", type: .error, duration: 2.0)
        case .contentTooLong:
            return ToastMessage("50자를 초과할 수 없습니다", type: .error, duration: 2.5)
        case .dailyLimitReached:
            return ToastMessage("하루 3번까지만 사용할 수 있습니다", type: .info, duration: 3.0)
        case .networkError:
            return ToastMessage("네트워크 연결을 확인해주세요", type: .error, duration: 3.0)
        case .serverError(let message):
            return ToastMessage(message, type: .error, duration: 3.0)
        default:
            return ToastMessage("알 수 없는 오류가 발생했습니다", type: .error, duration: 3.0)
        }
    }
}
