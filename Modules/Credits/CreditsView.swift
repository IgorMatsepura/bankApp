//
//  CreditsView.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var tabCoordinator: TabCoordinator
    @State private var selectedCredit: CreditProduct?
    
    let creditProducts = [
        CreditProduct(name: "Personal Loan", rate: "9.9%", maxAmount: 50000, term: "1-5 years", icon: "person.fill"),
        CreditProduct(name: "Car Loan", rate: "7.5%", maxAmount: 30000, term: "1-7 years", icon: "car.fill"),
        CreditProduct(name: "Mortgage", rate: "5.9%", maxAmount: 200000, term: "5-30 years", icon: "house.fill"),
        CreditProduct(name: "Education Loan", rate: "8.5%", maxAmount: 15000, term: "1-10 years", icon: "book.fill"),
        CreditProduct(name: "Business Loan", rate: "11.5%", maxAmount: 100000, term: "1-10 years", icon: "briefcase.fill")
    ]
    
    var body: some View {
        NavigationStack(path: $tabCoordinator.cardsPath) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(creditProducts) { product in
                        CreditCard(product: product)
                            .onTapGesture {
                                selectedCredit = product
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedCredit) { product in
                CreditDetailView(product: product)
            }
        }
    }
}

#Preview {
    CreditsView().environmentObject(TabCoordinator())
}


struct CreditCard: View {
    let product: CreditProduct
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "00C853").opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: product.icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "00C853"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("from \(product.rate) • up to \(formatMoney(product.maxAmount))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Term: \(product.term)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func formatMoney(_ amount: Double) -> String {
        if amount >= 1000 {
            return "\(Int(amount / 1000))k"
        }
        return "\(Int(amount))"
    }
}


struct CreditDetailView: View {
    let product: CreditProduct
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var term = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0F").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Іконка
                    ZStack {
                        Circle()
                            .fill(Color(hex: "00C853").opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: product.icon)
                            .font(.system(size: 35))
                            .foregroundColor(Color(hex: "00C853"))
                    }
                    .padding(.top, 40)
                    
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        InfoRow(title: "Interest Rate", value: product.rate)
                        InfoRow(title: "Maximum Amount", value: formatMoney(product.maxAmount))
                        InfoRow(title: "Loan Term", value: product.term)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        // Apply for credit
                    } label: {
                        Text("Apply Now")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "00C853"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Loan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color(hex: "00C853"))
                }
            }
        }
    }
    
    private func formatMoney(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "UAH"
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount) UAH"
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
