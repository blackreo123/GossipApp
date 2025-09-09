//
//  UsageState.swift
//  GossipApp
//
//  Created by JIHA YOON on 2025/09/03.
//

import Foundation

struct UsageResponse: Codable {
    let usage: Int
    let remaining: Int
    let resetTime: String
}
