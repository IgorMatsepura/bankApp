//
//  CardItemView.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI

// MARK: - CardItemView
struct CardItemView: View {
    let card: Card
    let info: Info
    let isCardSelected: Bool
    let selectedIndex: Int
    let currentIndex: Int
    let isCurrentCard: Bool
    let cardCount: Int
    let onTap: () -> Void
    @State private var isFlipped = false
    @State private var cvvMode: CVVMode = .dynamic("180")
    @State private var dragOffset: CGFloat = 0
    private var isSelected: Bool { isCurrentCard && isCardSelected }
    private var shouldApplyEffects: Bool { cardCount > 1 }
    
    @State private var showTransferSheet = false
    @State private var showTopUpSheet = false
    
    var body: some View {
        ZStack {
            if isCurrentCard && isCardSelected && !isFlipped {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("\(card.currency) \(String(format: "%.2f", card.balance))")
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .offset(y: -140)
                }
                
            }
            cardFront
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .rotation3DEffect(
                    .degrees(isCurrentCard && isCardSelected ? 70 : 0),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.3
                )
                .scaleEffect(isCurrentCard && isCardSelected ? 0.9 : 1, anchor: .top)
                .offset(y: isCurrentCard && isCardSelected ? -20 : (cardCount == 1 ? 0 : 40))
            if isCurrentCard && isCardSelected && !isFlipped  {
                CardActionsView { action in
                    // TODO: events
                    print(action)
                    switch action {
                    case .transfer:
                        showTransferSheet = true
                    case .other:
                        showTopUpSheet = true
                    default:
                        print(action.title)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .offset(y: 70)
            }
            cardBack
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
//        .clipShape(.rect(cornerRadius: 10))
        .frame(height: CardLayout.cardHeight)
        .contentShape(.rect)
        .onTapGesture {
            if isCurrentCard && isCardSelected {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            } else {
                onTap()
            }
        }
        .padding(.vertical, isCurrentCard && isCardSelected ? 60 : (cardCount == 1 ? 0 : 0))
        .visualEffect { [info, isCardSelected] content, proxy in

            let rect = proxy.frame(in: .scrollView)
            let bounds = info.containerSize
            let pushOffset = selectedIndex < currentIndex
            ? (bounds.height - rect.minY)
            : -rect.minY
            let scale: CGFloat = selectedIndex < currentIndex ? 1 : 0.95

            return content
                .scaleEffect(isCardSelected ? (isCurrentCard ? 1 : scale) : 1, anchor: .top)
                .offset(y: isCardSelected ? pushOffset : 0)
                .opacity(isCardSelected ? (isCurrentCard ? 1 : 0) : 1)
        }
        .allowsHitTesting(isCardSelected ? isCurrentCard : true)
        .onChange(of: isCardSelected) { _, newValue in
            if !newValue {
                isFlipped = false
            }
        }
        .sheet(isPresented: $showTransferSheet) {
            TransferView(card: card)
        }

        .sheet(isPresented: $showTopUpSheet) {
            TopUpView(card: card)
        }
    }
    
    
    
    
    private var cardFront: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .overlay { cardBackground }
            .overlay { cardContent }
    }
    
    private var cardBackground: some View {
        Image(card.cardBackground)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    
    
    
    private var cardContent: some View {
        VStack {
            HStack {
                Text(card.cardTitle)
                    .monospaced()
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer(minLength: 0)
                
                Image(card.cardType)
                    .resizable()
                    .renderingMode(card.cardType == "applePay" ? .template : .original)
                    .foregroundStyle(.white)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
            }
            .offset(y: -10)
            Spacer(minLength: 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.holderName)
                Text("**** **** **** \(card.id.suffix(4).uppercased())")
            }
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
    }
    
    
    
    private var cardBack: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.white, Color(hex: "#F0F0F5")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: "#B0B0B8").opacity(0.6))
                        .frame(height: 52)
                        .padding(.top, 28)

                    Spacer(minLength: 0)

                    HStack {
                        Spacer(minLength: 0)

                        HStack(spacing: 12) {
                            switch cvvMode {
                            case .static:
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                        .frame(width: 44, height: 44)
                                    Text("CVV")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundStyle(.gray)
                                }
                                .onTapGesture { cvvMode = .dynamic("991") }

                            case .dynamic:
                                CVVTimerView()
                            }
                        
                        }
                        .padding(.horizontal, 12)
                    }

                    .padding(.bottom, 20)
                }
                
            }
            .clipShape(.rect(cornerRadius: 10))
           
    }
}

#Preview {
    CardsView()
    
}

enum CVVMode {
    case `static`           // •••
    case dynamic(String)    // реальний код "847"
}




// MARK: - TransferView
struct TransferView: View {
    let card: Card
    @EnvironmentObject var viewModel: CardsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var selectedToAccount: Account?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var otherAccounts: [Account] {
        viewModel.otherAccounts(excludingCurrency: card.currency)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sender") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(card.cardTitle)
                                .font(.subheadline)
                            Text("\(card.currency) account")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(card.currency) \(String(format: "%.2f", card.balance))")
                            .font(.headline)
                    }
                }
                
                Section("Recipient") {
                    if otherAccounts.isEmpty {
                        Text("No other accounts available")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select account", selection: $selectedToAccount) {
                            Text("Select account").tag(nil as Account?)
                            ForEach(otherAccounts) { account in
                                HStack {
                                    Text(account.currency)
                                    Spacer()
                                    Text("\(account.currency) \(String(format: "%.2f", account.balance))")
                                }
                                .tag(account as Account?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            guard let toAccount = selectedToAccount,
                                  let amountValue = Double(amount) else { return }
                            let _ = try? await viewModel.transfer(from: card, to: toAccount.id, amount: amountValue)
                            dismiss()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Transfer")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if selectedToAccount == nil && !otherAccounts.isEmpty {
                    selectedToAccount = otherAccounts.first
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        selectedToAccount != nil && !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
    

}

// MARK: - TopUpView
struct TopUpView: View {
    let card: Card
    @EnvironmentObject var viewModel: CardsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Top Up") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(card.cardTitle)
                                .font(.subheadline)
                            Text("\(card.currency) account")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(card.currency) \(String(format: "%.2f", card.balance))")
                            .font(.headline)
                    }
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            guard let amountValue = Double(amount) else { return }
                            await viewModel.performTopUp(for: card, amount: amountValue)
                            dismiss()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Top Up")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Top Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
    

}
