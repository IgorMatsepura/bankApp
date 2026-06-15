//
//  OperationsViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 12.06.2026.
//

import SwiftUI
import Combine

// MARK: - OperationsViewModel
@MainActor
final class OperationsViewModel: ObservableObject {
    @Published var operations: [Operation] = []
    @Published var isLoading = false
    @Published var error: String?
 
    private let network = NetworkService.shared
 
    func loadOperations(accountId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let transfers = try await network.transferHistory(accountId: accountId)
            // Маппінг TransferResponse → Operation
            operations = transfers.map { transfer in
                let isIncoming = transfer.toAccountId == accountId
                return Operation(
                    id: transfer.id,
                    type: isIncoming ? .income : .expense,
                    amount: transfer.amount,
                    currency: "UAH",
                    description: isIncoming ? "Incoming transfer" : "Outgoing transfer",
                    createdAt: transfer.createdAt,
                    fromAccountId: transfer.fromAccountId,
                    toAccountId: transfer.toAccountId,
                    status: .completed
                )
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
