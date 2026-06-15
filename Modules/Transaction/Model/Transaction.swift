//
//  Transaction.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI


struct Operation: Identifiable, Codable {
    let id: String
    let type: OperationType
    let amount: Double
    let currency: String
    let description: String
    let createdAt: String
    let fromAccountId: String?
    let toAccountId: String?
    let status: OperationStatus
 
    var isIncoming: Bool { type == .income }
 
    var formattedAmount: String {
        let sign = isIncoming ? "+" : "-"
        return "\(sign)\(currency) \(String(format: "%.2f", amount))"
    }
 
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else { return createdAt }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }
}
 
enum OperationType: String, Codable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"
}
 
enum OperationStatus: String, Codable {
    case completed = "completed"
    case pending = "pending"
    case failed = "failed"
 
    var color: Color {
        switch self {
        case .completed: return .green
        case .pending:   return .orange
        case .failed:    return .red
        }
    }
}

struct Transaction: Identifiable, Hashable, Codable {
    let id: UUID
    let amount: Double
    let date: Date
    let description: String
}
