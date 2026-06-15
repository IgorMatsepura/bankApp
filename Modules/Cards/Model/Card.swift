//
//  Card.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import Foundation


struct Card: Identifiable, Hashable, Codable {
    let id: String
    let holderName: String
    var balance: Double
    let currency: String
    let cardBackground: String
    let cardTitle: String
    let cardType: String
    let expiryDate: String

    init(
        id: String,
        accountNumber: String,
        holderName: String,
        balance: Double,
        currency: String,
        cardBackground: String,
        cardTitle: String,
        cardType: String,
        expiryDate: String
    ) {
        self.id = id
        self.holderName = holderName
        self.balance = balance
        self.currency = currency
        self.cardBackground = cardBackground
        self.cardTitle = cardTitle
        self.cardType = cardType
        self.expiryDate = expiryDate
    }

    // Init from back
    init(from account: Account, holderName: String) {
        self.id = account.id
        self.holderName = holderName
        self.balance = account.balance
        self.currency = account.currency
//        self.cardBackground = "card\(Int.random(in: 1...5))"
        self.cardBackground = Card.backgroundForAccount(account.id)

        self.cardTitle = "\(account.currency) Account"
        self.cardType = "visa"
        self.expiryDate = "12/27"
    }
    
    static func backgroundForAccount(_ accountId: String) -> String {
        let hash = abs(accountId.hashValue)
        let number = (hash % 5) + 1
        return "card\(number)"
    }
}



extension Card {
    static let mock: Card = Card(
        id: "1",
        accountNumber: "1234 4531 0001 1234",
        holderName: "ANNA IVANOVA",
        balance: 15432.75,
        currency: "USD",
        cardBackground: "card1",
        cardTitle: "Everyday Card",
        cardType: "visa",
        expiryDate: "12/27"
    )

    static let mocks: [Card] = [
        Card(
            id: "2",
            accountNumber: "0001 1111 2222 1234",
            holderName: "IGOR MATSEPURA",
            balance: 15432.75,
            currency: "USD",
            cardBackground: "card2",
            cardTitle: "Everyday Card",
            cardType: "visa",
            expiryDate: "12/27"
        ),
        Card(
            id: "3",
            accountNumber: "**** **** **** 9876",
            holderName: "IGOR MATSEPURA",
            balance: 2034.10,
            currency: "EUR",
            cardBackground: "card3",
            cardTitle: "Travel Card",
            cardType: "mc",
            expiryDate: "06/26"
        ),
        Card(
            id: "4",
            accountNumber: "**** **** **** 0011",
            holderName: "IGOR MATSEPURA",
            balance: 48210.00,
            currency: "USD",
            cardBackground: "card4",
            cardTitle: "Business Card",
            cardType: "mc",
            expiryDate: "09/28"
        ),
        Card(
            id: "5",
            accountNumber: "**** **** **** 0011",
            holderName: "IGOR MATSEPURA",
            balance: 48210.00,
            currency: "UAH",
            cardBackground: "card5",
            cardTitle: "Apple Card",
            cardType: "applePay",
            expiryDate: "03/30"
        )
    ]
}

