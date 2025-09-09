//
//  View+Extention.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/08.
//

import Foundation
import SwiftUI

extension View {
    func toast(_ toastManager: ToastManager) -> some View {
        self.modifier(ToastModifier(toastManager: toastManager))
    }
}
