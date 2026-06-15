//
//  TransactionViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import SwiftUI
import Combine


// MARK: - TransactionViewModel
@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransferResponse] = []
    @Published var isLoading = false
    
    private let network = NetworkService.shared
    
    func loadTransactions(accountId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [TransferResponse] = try await network.fetchArray(.accountTransfers(accountId))
            self.transactions = response
            print("✅ Loaded \(transactions.count) transactions")
        } catch {
            print("❌ Failed to load transactions: \(error)")
        }
    }
}
