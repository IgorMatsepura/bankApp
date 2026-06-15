//
//  MainTabView.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI


struct MainTabView: View {
    @EnvironmentObject var coordinator: TabCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var cardsViewModel: CardsViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch coordinator.selectedTab {
                case .cards:
                        CardsView()
                          .environmentObject(cardsViewModel)
                case .credits:  CreditsView()
                case .savings:  SavingsView()
                case .exchange: ServicesGridView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                if !coordinator.isTabBarHidden {
                    CustomTabBar(selectedTab: $coordinator.selectedTab, onSearchTap: {
                        
                    })
                }
            }
//            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}


#Preview {
    let coordinator = AppCoordinator()
       let tabCoordinator = TabCoordinator()
       
       return MainTabView()
           .environmentObject(coordinator)
           .environmentObject(tabCoordinator)
           .environmentObject(coordinator.cardsViewModel)
}



struct ExchangeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Exchange")
                .font(.title)
            
            Spacer()
            
            Button(action: {
                appCoordinator.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
