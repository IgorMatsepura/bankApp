//
//  AddCardViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 14.06.2026.
//

import SwiftUI
import Combine

// MARK: - AddCardViewModel
@MainActor
final class AddCardViewModel: ObservableObject {
    @Published var selectedCurrency = "UAH"
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var error: String?
 
    private let network = NetworkService.shared
 
    func createCard() async {
        isLoading = true
        defer { isLoading = false }
        error = nil
        do {
            let _ = try await network.createAccount(currency: selectedCurrency)
            print("✅ Created account: ")
            isSuccess = true
        } catch {
            print("❌ createCard error: \(error)")
            self.error = error.localizedDescription
        }
    }
}
 
