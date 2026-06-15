//
//  bankAppApp.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI

@main
struct bankAppApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var tabCoordinator = TabCoordinator()
    
    var body: some Scene {
        WindowGroup {
            switch coordinator.route {
            case .splash:
                SplashView()
                    .environmentObject(coordinator)
            case .auth:
                AuthView(viewModel: coordinator.authViewModel)
                    .environmentObject(coordinator)
            case .main:
                MainTabView()
                    .environmentObject(coordinator)
                    .environmentObject(tabCoordinator)                
                    .environmentObject(coordinator.cardsViewModel)
            }
        }
    }
}
