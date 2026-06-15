//
//  CreditProduct.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import Foundation

struct CreditProduct: Identifiable {
    let id = UUID()
    let name: String
    let rate: String
    let maxAmount: Double
    let term: String
    let icon: String
}
