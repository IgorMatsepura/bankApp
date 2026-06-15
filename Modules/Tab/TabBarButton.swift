//
//  TabBarButton.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI


enum TabBarItem: Int, CaseIterable {
    case cards
    case credits
    case savings
    case exchange

    var title: String {
        switch self {
        case .cards:    return "Cards"
        case .credits:  return "Credit"
        case .savings:  return "Payments"
        case .exchange: return "Services"
        }
    }

    var icon: String {
        switch self {
        case .cards:    return "creditcard.fill"
        case .credits:  return "banknote.fill"
        case .savings:  return "arrow.left.arrow.right"
        case .exchange: return "square.grid.2x2"
        }
    }
}


// MARK: - CustomTabBar
struct CustomTabBar: View {
    @Binding var selectedTab: TabBarItem
    var onSearchTap: () -> Void

    private let accent = Color(hex: "#00C853")
    private let background = Color(hex: "#1C1C1E")
    private let inactive = Color.black

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabBarItem.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    accent: accent,
                    inactive: inactive
                ) {
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
//                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.black.opacity(0.05))
                )
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - TabBarButton
struct TabBarButton: View {
    let tab: TabBarItem
    let isSelected: Bool
    let accent: Color
    let inactive: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .medium))
                    .symbolEffect(.bounce, value: isSelected)
                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .foregroundColor(isSelected ? accent : inactive)
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    MainTabView()
        .environmentObject(TabCoordinator())
}

