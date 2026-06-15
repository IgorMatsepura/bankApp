//
//  TransferViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 12.06.2026.
//

import SwiftUI
import Combine


// MARK: - TransferViewModel
@MainActor
final class TransferViewModel: ObservableObject {
    @Published var toCardNumber = ""
    @Published var amount = ""
    @Published var cardInfo: CardBINInfo?
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var error: String?
 
    var fromAccount: Card?
    var onSuccess: (() -> Void)?
 
    private let network = NetworkService.shared
 
    var isFormValid: Bool {
        !toCardNumber.isEmpty &&
        toCardNumber.count == 16 &&
        !amount.isEmpty &&
        (Double(amount) ?? 0) > 0
    }
 
    var amountDouble: Double { Double(amount) ?? 0 }
 
    // Lookup BIN коли введено 6+ цифр
    func lookupCard() async {
        guard toCardNumber.count >= 6 else {
            cardInfo = nil
            return
        }
        do {
            cardInfo = try await network.checkCard(toCardNumber)
        } catch {
            cardInfo = nil
        }
    }
 
    func transfer() async {
        guard let from = fromAccount, isFormValid else { return }
        isLoading = true
        defer { isLoading = false }
        error = nil
        do {
            _ = try await network.transfer(
                from: from.id,
                to: toCardNumber,
                amount: amountDouble
            )
            isSuccess = true
            onSuccess?()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
