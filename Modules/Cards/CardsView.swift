//
//  CardsView.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI

// MARK: - Layout Constants
enum CardLayout {
    static let cardHeight: CGFloat = 220
    static let stackSpacing: CGFloat = -150
    static let sheetSpacing: CGFloat = 85
    static let sheetMaxOffset: CGFloat = 20
    static let scrollThreshold: CGFloat = 10
    static let safeAreaPadding: CGFloat = 15
}

// MARK: - Info (UI geometry state)
struct Info {
    var scrollOffset: CGFloat = 0
    var containerSize: CGSize = .zero
    var safeArea: EdgeInsets = .init()
    var minY: CGFloat = 0
}


// MARK: - CardsView
struct CardsView: View {
//    @StateObject var viewModel = CardsViewModel()
    @EnvironmentObject var viewModel: CardsViewModel
    @EnvironmentObject var tabCoordinator: TabCoordinator
    @State private var info: Info = .init()
    private let animation: Animation = .interactiveSpring(response: 0.6, dampingFraction: 0.9)
    @State private var isNavigationTitleHidden = false
    @State private var showAddCard = false

    var body: some View {
        NavigationStack(path: $tabCoordinator.cardsPath) {
            ScrollView(.vertical) {
                VStack(spacing:  CardLayout.stackSpacing) {
//                    if viewModel.isLoading {
//                        ForEach(0..<2, id: \.self) { _ in
//                            SkeletonCardView()
//                        }
//                    } else
                    if viewModel.cards.isEmpty {
                        EmptyCardsView()
                            .onTapGesture {
                                showAddCard = true
                            }
                    } else {
                        ForEach(viewModel.cards) { card in
                            CardItemView(
                                card: card,
                                info: info,
                                isCardSelected: viewModel.isCardSelected,
                                selectedIndex: viewModel.selectedIndex(),
                                currentIndex: viewModel.index(of: card),
                                isCurrentCard: card.id == viewModel.selectedCard?.id,
                                cardCount: viewModel.cards.count
                            ) {
                                withAnimation(animation) {
                                    viewModel.selectCard(card)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 130)
            }
   
            .onChange(of: viewModel.isCardSelected) { _, newValue in
                isNavigationTitleHidden = info.scrollOffset > CardLayout.scrollThreshold || newValue
            }
            .scrollIndicators(.hidden)
            .safeAreaPadding(CardLayout.safeAreaPadding)
            .scrollDisabled(viewModel.isCardSelected)
            .navigationTitle(isNavigationTitleHidden ? "" : "Wallet")
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.y + $0.contentInsets.top
            } action: { _, newValue in
                guard abs(info.scrollOffset - newValue) > 1 else { return }
                info.scrollOffset = newValue
                let shouldHide = newValue > CardLayout.scrollThreshold || viewModel.isCardSelected
                if isNavigationTitleHidden != shouldHide {
                    isNavigationTitleHidden = shouldHide
                }
                
            }
            .onGeometryChange(for: CGFloat.self) {
                $0.frame(in: .global).minY
            } action: { _, newValue in
                let newMinY = newValue - info.safeArea.top
                 guard abs(info.minY - newMinY) > 2 else { return }
                 info.minY = newMinY
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
         
                toolbarContent
            }
            .navigationDestination(for: CardsRoute.self) { route in
                switch route {
                case .profile:
                    ProfileView()
                        .environmentObject(tabCoordinator)
                        .navigationBarBackButtonHidden(true)
                default:
                    EmptyView()
                }
            }
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
            .sheet(isPresented: $showAddCard, onDismiss: {
                Task { await viewModel.loadCards() }
            }) {
                AddCardView()
                    .environmentObject(viewModel)
            }
            // hide tab bar when scroll
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.y
            } action: { oldValue, newValue in
                if newValue > oldValue + 10 {
                    withAnimation {
                        tabCoordinator.isTabBarHidden = true
                    }
                }
                if newValue < oldValue - 10 {
                    withAnimation {
                        tabCoordinator.isTabBarHidden = false
                    }
                }
            }
        }
        
        .sheet(item: $viewModel.selectedCard) { card in
            let minHeight = info.containerSize.height - info.minY - (CardLayout.cardHeight + CardLayout.sheetSpacing)
            let maxHeight = info.containerSize.height - info.minY + CardLayout.sheetMaxOffset
            
            TransactionSheetView(card: card)
                .presentationDetents([.height(minHeight), .height(maxHeight)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(maxHeight)))
                .interactiveDismissDisabled()
        }
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: { _, newValue in
            info.containerSize = newValue
        }
        .onGeometryChange(for: EdgeInsets.self) {
            $0.safeAreaInsets
        } action: { _, newValue in
            info.safeArea = newValue
        }
        .task {
            await viewModel.loadCards()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            if viewModel.isCardSelected {
                Button("Close", systemImage: "xmark") {
                    withAnimation(animation) {
                        viewModel.deselectCard()
                    }
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(
                viewModel.isCardSelected ? "Edit" : "Add Card",
                systemImage: viewModel.isCardSelected ? "creditcard.and.numbers" : "plus"
            ) {
                // TODO: handle action
                if viewModel.isCardSelected {
                    // TODO: edit
                } else {
                    showAddCard = true
                }
            }
        }
        
        if !viewModel.isCardSelected {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Search", systemImage: "magnifyingglass") {
                    // TODO: handle search
                    print("Search")
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button("Options", systemImage: "ellipsis") {
                // TODO: handle options
                print("More Options")

            }
        }
        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .topBarTrailing) {
            UserAvatarButton(onTap: {
                print("Avat")
                tabCoordinator.showProfile()
            })
        }
    }
}

#Preview {
    CardsView()
        .environmentObject(CardsViewModel())
        .environmentObject(TabCoordinator())

}



// MARK: - Skeleton
struct SkeletonCardView: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(opacity))
            .frame(height: CardLayout.cardHeight)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                    opacity = 0.1
                }
            }
    }
}

// MARK: - Empty
struct EmptyCardsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        style: StrokeStyle(lineWidth: 1.5, dash: [8, 4])
                    )
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(height: CardLayout.cardHeight)

                VStack(spacing: 12) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))

                    Text("No cards yet")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Add your first card to get started")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, CardLayout.safeAreaPadding)
    }
}
