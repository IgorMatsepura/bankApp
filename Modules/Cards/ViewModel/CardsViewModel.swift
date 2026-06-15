//
//  CardsViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI
import Combine

// MARK: - CardsViewModel
@MainActor
final class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var accounts: [Account] = []
    @Published var selectedCard: Card?
    @Published var isLoading = false
    @Published var error: String?
    private var customerName: String = ""
    @Published var hasLoaded = false 
    private let network = NetworkService.shared
 
    var isCardSelected: Bool { selectedCard != nil }
 
    // MARK: - Card selection
    func selectCard(_ card: Card) { selectedCard = card }
    func deselectCard() { selectedCard = nil }
 
    func selectedIndex() -> Int {
        cards.firstIndex(where: { $0.id == selectedCard?.id }) ?? 0
    }
 
    func index(of card: Card) -> Int {
        cards.firstIndex(where: { $0.id == card.id }) ?? 0
    }
 
    func selectNextCard() {
        guard let current = selectedCard,
              let index = cards.firstIndex(where: { $0.id == current.id }),
              index + 1 < cards.count else { return }
        selectedCard = cards[index + 1]
    }
 
    func selectPreviousCard() {
        guard let current = selectedCard,
              let index = cards.firstIndex(where: { $0.id == current.id }),
              index - 1 >= 0 else { return }
        selectedCard = cards[index - 1]
    }
    
    // MARK: - Network
    func loadCards() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let customer = try await NetworkService.shared.me()
            try Task.checkCancellation()
            
            let accounts = try await NetworkService.shared.myAccounts()
            try Task.checkCancellation()
            self.accounts = accounts
//            let groupedAccounts = Dictionary(grouping: accounts, by: { $0.currency })
            
            let cards = accounts.map { account in
                Card(from: account, holderName: customer.name)
            }
                //group for valut
//            let cards = groupedAccounts.map { currency, accountsInCurrency -> Card in
//                let totalBalance = accountsInCurrency.reduce(0) { $0 + $1.balance }
//                
//                let card = Card(from: accountsInCurrency.first!, holderName: customer.name)
//                return Card(
//                    id: currency,
//                    accountNumber: "",
//                    holderName: customer.name,
//                    balance: totalBalance,
//                    currency: currency,
//                    cardBackground: card.cardBackground,
//                    cardTitle: "\(currency) рахунок",
//                    cardType: "visa",
//                    expiryDate: "12/27"
//                )
//            }
            
            self.cards = cards.sorted { $0.currency < $1.currency }
            self.hasLoaded = true 
            
        } catch is CancellationError {
            print("Load cards was cancelled")
            self.hasLoaded = false
        } catch {
            print("Failed to load cards: \(error)")
            self.hasLoaded = false
        }
    }
    
    // В CardsViewModel.transfer
    func transfer(from card: Card, to toAccountId: String, amount: Double) async throws -> TransferResponse {
        guard let fromAccount = accounts.first(where: { $0.currency == card.currency }) else {
            throw NetworkError.custom("Sender account not found")
        }
        
        let response = try await network.transfer(
            from: fromAccount.id,
            to: toAccountId,
            amount: amount
        )
        isLoading = true
        await loadCards()
        return response
    }
    
    func performTopUp(for card: Card, amount: Double) async {
        guard let account = accounts.first(where: { $0.currency == card.currency }) else {
            error = "Account not found"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await network.topUp(accountId: account.id, amount: amount)
            await loadCards()
        } catch {
            self.error = error.localizedDescription
        }
    }

    
     private func topUp(accountId: String, amount: Double) async throws -> Double {
        let response = try await network.topUp(accountId: accountId, amount: amount)
        if let index = cards.firstIndex(where: { $0.id == accountId }) {
            cards[index].balance = response.balance
        }
        return response.balance
    }
    
    func otherAccounts(excludingCurrency currency: String) -> [Account] {
        accounts.filter { $0.currency != currency }
    }
    
    func createAccount(currency: String, initialDeposit: Double = 0.0) async throws -> Account {
        let newAccount = try await network.createAccount(currency: currency, initialDeposit: initialDeposit)
        await loadCards()
        return newAccount
    }
      
}
