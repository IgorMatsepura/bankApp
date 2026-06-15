//
//  CardActionsView.swift
//  bankApp
//
//  Created by Igor Matsepura on 12.06.2026.
//

import SwiftUI

// MARK: - CardAction
enum CardAction: CaseIterable {
    case transfer
    case iban
    case scheduled
    case other

    var title: String {
        switch self {
        case .transfer:  return "Transfer\nto card"
        case .iban:      return "Payment\nby IBAN"
        case .scheduled: return "Scheduled\npayments"
        case .other:     return "All\ncards"
        }
    }

    var icon: String {
        switch self {
        case .transfer:  return "wallet.bifold.fill"
        case .iban:      return "doc.text.fill"
        case .scheduled: return "calendar.badge.minus"
        case .other:     return "command.square.fill"
        }
    }
}

// MARK: - CardActionsView
struct CardActionsView: View {
    var onAction: (CardAction) -> Void

    var body: some View {
        VStack(spacing: 3) {

            HStack(spacing: 0) {
                ForEach(CardAction.allCases, id: \.self) { action in
                    Button {
                        onAction(action)
                    } label: {
                        VStack(spacing: 3) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#1A1A2E"))
                                    .frame(width: 52, height: 52)

                                Image(systemName: action.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Color(hex: "#E8E0FF"))
                            }

                            Text(action.title)
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    CardsView()
}
