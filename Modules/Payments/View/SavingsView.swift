//
//  SavingsView.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import SwiftUI

struct SavingsView: View {
    @EnvironmentObject var tabCoordinator: TabCoordinator
    @State private var selectedPayment: Payment?
    
    let payments = [
        Payment(icon: "house.fill", name: "Rent", amount: 1200, dueDay: 5, color: "00C853"),
        Payment(icon: "bolt.fill", name: "Electricity", amount: 85, dueDay: 15, color: "FF9800"),
        Payment(icon: "drop.fill", name: "Water", amount: 45, dueDay: 20, color: "2196F3"),
        Payment(icon: "wifi", name: "Internet", amount: 60, dueDay: 10, color: "9C27B0"),
        Payment(icon: "phone.fill", name: "Mobile", amount: 35, dueDay: 25, color: "00C853"),
        Payment(icon: "tv.fill", name: "TV Subscription", amount: 25, dueDay: 1, color: "E91E63")
    ]
    
    var body: some View {
        NavigationStack(path: $tabCoordinator.cardsPath) {
            ScrollView {
                VStack(spacing: 16) {
                    // Total due
                    TotalDueCard(total: payments.reduce(0) { $0 + $1.amount })
                        .padding(.bottom, 8)
                    
                    // Payment list
                    ForEach(payments) { payment in
                        PaymentCard(payment: payment)
                            .onTapGesture {
                                selectedPayment = payment
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
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
            .navigationTitle("Payments")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedPayment) { payment in
                PaymentDetailView(payment: payment)
            }
        }
    }
}

#Preview {
    SavingsView()
        .environmentObject(TabCoordinator())
}


struct TotalDueCard: View {
    let total: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Due This Month")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("$ \(String(format: "%.2f", total))")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "00C853").opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "00C853"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct PaymentCard: View {
    let payment: Payment
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: payment.color).opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: payment.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: payment.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Due: \(payment.dueDay)th of month")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$ \(String(format: "%.2f", payment.amount))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Button("Pay Now") {
                    // Action
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: "00C853").opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}



struct PaymentDetailView: View {
    let payment: Payment
    @Environment(\.dismiss) private var dismiss
    @State private var cardNumber = ""
    @State private var cvv = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0F").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Payment info
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: payment.color).opacity(0.15))
                                .frame(width: 70, height: 70)
                            Image(systemName: payment.icon)
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: payment.color))
                        }
                        
                        Text(payment.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("$ \(String(format: "%.2f", payment.amount))")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(hex: "00C853"))
                    }
                    .padding(.top, 40)
                    
                    // Card details
                    VStack(spacing: 16) {
                        AuthTextField(placeholder: "Card Number", icon: "creditcard", text: $cardNumber, keyboardType: .numberPad)
                        AuthTextField(placeholder: "CVV", icon: "lock", text: $cvv, keyboardType: .numberPad, isSecure: true)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button {
                        // Process payment
                        dismiss()
                    } label: {
                        Text("Pay \(payment.name)")
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
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color(hex: "00C853"))
                }
            }
        }
    }
}
