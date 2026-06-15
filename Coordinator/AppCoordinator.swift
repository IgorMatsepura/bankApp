//
//  AppCoordinator.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI
import Combine

enum AppRoute {
    case splash
    case auth
    case main
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var route: AppRoute = .splash
    @Published var authViewModel = AuthViewModel()
    private var cancellables = Set<AnyCancellable>()
    @Published var cardsViewModel = CardsViewModel()

    init() {
        authViewModel.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.route = .main
                } else if self?.route != .splash {
                    self?.route = .auth
                }
            }
            .store(in: &cancellables)
        
        Task {
            await authViewModel.checkAuthStatus()
            route = authViewModel.isAuthenticated ? .main : .auth
            
        }
    }
    
    func showMain() {
        route = .main
    }
    
    func logout(tabCoordinator: TabCoordinator) {
        authViewModel.logout()
        tabCoordinator.cardsPath = NavigationPath()
        tabCoordinator.selectedTab = .cards
        tabCoordinator.isTabBarHidden = false
        cardsViewModel.cards = []
        cardsViewModel.accounts = []
        route = .auth
    }
}

