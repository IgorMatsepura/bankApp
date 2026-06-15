//
//  Payment.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import Foundation


struct Payment: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let amount: Double
    let dueDay: Int
    let color: String
}
