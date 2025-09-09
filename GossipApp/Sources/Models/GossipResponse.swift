//
//  GossipResponse.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/03.
//

import Foundation

struct GossipResponse: Codable {
    let success: Bool
    let queuePosition: Int
    let userUsage: Int
}
