//
//  ServicesMenuButton.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import SwiftUI

struct ServicesGridView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var tabCoordinator: TabCoordinator
    
    let services = [
        ServiceHelp(icon: "arrow.left.arrow.right", title: "Exchange", color: "00C853"),
        ServiceHelp(icon: "creditcard.fill", title: "Top Up", color: "2196F3"),
        ServiceHelp(icon: "qrcode.viewfinder", title: "Scan QR", color: "9C27B0"),
        ServiceHelp(icon: "bell.fill", title: "Notifications", color: "FF9800"),
        ServiceHelp(icon: "headphones", title: "Support", color: "E91E63"),
        ServiceHelp(icon: "doc.text.fill", title: "Statements", color: "00BCD4"),
        ServiceHelp(icon: "person.fill", title: "Profile", color: "00C853"),
        ServiceHelp(icon: "gear", title: "Settings", color: "6C63FF"),
        ServiceHelp(icon: "clock.fill", title: "History", color: "FF6B6B"),
        ServiceHelp(icon: "gift.fill", title: "Offers", color: "FFD93D")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(services) { service in
                            ServiceCube(service: service)
                                .onTapGesture {
                                    handleServiceTap(service)
                                    dismiss()
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Services")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "1a1a2e"),
                        Color(hex: "16213e"),
                        Color(hex: "0f3460")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private func handleServiceTap(_ service: ServiceHelp) {
        switch service.title {
        case "Exchange":
            tabCoordinator.selectedTab = .exchange
        case "Top Up":
            // Відкрити TopUp
            print("Top Up")
        case "Profile":
            // Відкрити Profile
            print("Profile")
        default:
            print("Selected: \(service.title)")
        }
    }
}


struct ServiceCube: View {
    let service: ServiceHelp
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: service.color).opacity(0.15))
                    .frame(height: 80)
                
                Image(systemName: service.icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: service.color))
            }
            
            Text(service.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
    }
}


#Preview {
    ServicesGridView()
        .environmentObject(AppCoordinator())
        .environmentObject(TabCoordinator())
}
