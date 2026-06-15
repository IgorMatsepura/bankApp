//
//  TransactionSheetView.swift
//  bankApp
//
//  Created by Igor Matsepura on 12.06.2026.
//

import SwiftUI

struct TransactionSheetView: View {
    let card: Card
    @StateObject private var viewModel = TransactionViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Transactions")
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(.black.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 25)
                .padding(.leading, 15)
                .padding(.bottom, 12)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.transactions.reversed(), id: \.id) { transaction in
                            TransactionRow(transaction: transaction, currentAccountId: card.id)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            await viewModel.loadTransactions(accountId: card.id)
        }
    }
}

// MARK: - TransactionRow
struct TransactionRow: View {
    let transaction: TransferResponse
    let currentAccountId: String
    
    private var isIncoming: Bool {
        transaction.toAccountId == currentAccountId
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(isIncoming ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: isIncoming ?  "arrow.up" :  "arrow.down" )
                        .foregroundColor(isIncoming ? .green : .red)
//                        .rotationEffect(.degrees(isIncoming ? 0 : 180))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isIncoming ? "Incoming Transfer" : "Outgoing Transfer")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(transaction.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
           
            Text("\(isIncoming ? "+" : "-") \(transaction.currency) \(String(format: "%.2f", transaction.amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isIncoming ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // Formating date 
    private func formatDate(_ dateString: String) -> String {
        let cleaned = dateString.replacingOccurrences(of: "T", with: " ")
        let withoutMillis = cleaned.split(separator: ".").first ?? ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")  // ← UTC
        
        guard let date = formatter.date(from: String(withoutMillis)) else {
            return dateString
        }
        
        let display = DateFormatter()
        display.dateFormat = "dd MMM yyyy, HH:mm"
        display.timeZone = .current  // ← Локальний
        
        return display.string(from: date)
    }
}


#Preview {
    CardsView()
        .environmentObject(CardsViewModel())
}
