//
//  AddCardView.swift
//  bankApp
//
//  Created by Igor Matsepura on 14.06.2026.
//

import SwiftUI

// MARK: - AddCardView
struct AddCardView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddCardViewModel()
    @State private var initialDeposit = "500"
    let currencies = ["UAH", "USD", "EUR", "GBP"]
    @State private var editSum: Bool = false
    @FocusState private var isAmountFocused: Bool

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0F").ignoresSafeArea()
 
            VStack(spacing: 0) {
                // Хедер
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("New Card")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Превью картки
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: cardGradient(for: viewModel.selectedCurrency),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .shadow(color: cardShadow(for: viewModel.selectedCurrency), radius: 20, y: 10)
                        .overlay {
                            HStack(spacing: 6) {
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(hex: "00C853"))
                                Text("Kinect Bank")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding(.vertical, 20)
                            Spacer()
                            VStack(alignment: .leading, spacing: 6) {
                                Text("**** **** **** ****")
                                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                HStack {
                                    Text("\(initialDeposit) \(viewModel.selectedCurrency)")
                                    
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .onTapGesture {
                                            editSum = true
                                        }
                                    Spacer()
                                    Text("12/27")
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .padding(.top, 60)
                            
                        }
                    VStack(alignment: .leading) {
                        HStack {
                            Text(viewModel.selectedCurrency)
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("**** **** **** ****")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.8))
                            Text("0.00 \(viewModel.selectedCurrency)")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .onTapGesture {
                                    editSum = true
                                }
                        }
                    }
                    .padding(24)
                }
                .padding(.horizontal, 24)
                .animation(.spring(response: 0.4), value: viewModel.selectedCurrency)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select currency")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 24)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(currencies, id: \.self) { currency in
                                CurrencyChip(
                                    currency: currency,
                                    isSelected: viewModel.selectedCurrency == currency
                                ) {
                                    viewModel.selectedCurrency = currency
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                if editSum {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Initial deposit")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 24)
                        
                        HStack {
                            TextField("0.00", text: $initialDeposit)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .onSubmit {
                                    editSum = false
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .onChange(of: isAmountFocused) { _, isFocused in
                                    if !isFocused {
                                        editSum = false
                                    }
                                }
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            editSum = false
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                    }
                                }
                            Text(viewModel.selectedCurrency)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.trailing, 24)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
 
                if let error = viewModel.error {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
 
                Button {
                    Task {
                        await viewModel.createCard()
                        if viewModel.isSuccess { dismiss() }
                    }
                } label: {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.black)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Open Card")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "#00C853"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .disabled(viewModel.isLoading)
            }
        }
    }
 
    private func cardGradient(for currency: String) -> [Color] {
        switch currency {
        case "USD": return [Color(hex: "#1a1a2e"), Color(hex: "#16213e")]
        case "EUR": return [Color(hex: "#0f3460"), Color(hex: "#533483")]
        case "GBP": return [Color(hex: "#2d1b69"), Color(hex: "#11998e")]
        default:    return [Color(hex: "#134e5e"), Color(hex: "#71b280")]
        }
    }
 
    private func cardShadow(for currency: String) -> Color {
        switch currency {
        case "USD": return Color(hex: "#1a1a2e").opacity(0.5)
        case "EUR": return Color(hex: "#533483").opacity(0.5)
        case "GBP": return Color(hex: "#11998e").opacity(0.5)
        default:    return Color(hex: "#71b280").opacity(0.5)
        }
    }
}
 
// MARK: - CurrencyChip
struct CurrencyChip: View {
    let currency: String
    let isSelected: Bool
    let onTap: () -> Void
 
    var flag: String {
        switch currency {
        case "USD": return "🇺🇸"
        case "EUR": return "🇪🇺"
        case "GBP": return "🇬🇧"
        default:    return "🇺🇦"
        }
    }
 
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(flag)
                Text(currency)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? .black : .white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "#00C853") : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
#Preview {
    AddCardView()
}
