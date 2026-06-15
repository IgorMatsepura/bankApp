//
//  TabCoordinator.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI
import Combine

enum CardsRoute: Hashable {
    case cardDetail(Card)
    case addCard
    case transaction(Transaction)
    case profile
}


@MainActor
final class TabCoordinator: ObservableObject {
    @Published var selectedTab: TabBarItem = .cards
    
    @Published var cardsPath = NavigationPath()
    @Published var isTabBarHidden = false

    // MARK: - Cards
    func showCardDetail(_ card: Card) {
        cardsPath.append(CardsRoute.cardDetail(card))
    }
    
    func showAddCard() {
        cardsPath.append(CardsRoute.addCard)
    }
    
    func showTransaction(_ transaction: Transaction) {
        cardsPath.append(CardsRoute.transaction(transaction))
    }
    
    func popCards() {
        cardsPath.removeLast()
    }
    
    func popToRootCards() {
        isTabBarHidden = false
        cardsPath.removeLast(cardsPath.count)
    }
    
    func showProfile() {
        isTabBarHidden = true
        print("🖼️ 2. showProfile called")
        cardsPath.append(CardsRoute.profile)
        print("🖼️ 3. Path after append: \(cardsPath)")
    }
}
