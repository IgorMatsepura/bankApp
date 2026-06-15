//
//  NetworkService.swift
//  bankApp
//
//  Created by Igor Matsepura on 12.06.2026.
//

import Foundation

// MARK: - Endpoints
enum Endpoint {
    // Auth
    case register
    case login
    case me
 
    // Customers
    case createCustomer
    case customer(String)
 
    // Accounts
    case createAccount
    case myAccounts
    case balance(String)
    case accountTransfers(String)
 
    // Transfers
    case transfer
 
    // Cards
    case checkCard(String)
    
    case topup
 
    var path: String {
        switch self {
        case .register:                     return "/api/v1/auth/register"
        case .login:                        return "/api/v1/auth/login"
        case .me:                           return "/api/v1/auth/me"
        case .createCustomer:               return "/api/v1/customers"
        case .customer(let id):             return "/api/v1/customers/\(id)"
        case .createAccount:                return "/api/v1/accounts"
        case .myAccounts:                   return "/api/v1/my/accounts"
        case .balance(let id):              return "/api/v1/accounts/\(id)/balance"
        case .accountTransfers(let id):     return "/api/v1/accounts/\(id)/transfers"
        case .transfer:                     return "/api/v1/transfers"
        case .checkCard(let number):        return "/api/v1/check-card/\(number)"
        case .topup:                        return "/api/v1/topup"
               
        }
    }
 
    var method: String {
        switch self {
        case .register, .login, .createCustomer, .createAccount, .transfer, .topup:
            return "POST"
        default:
            return "GET"
        }
    }
}

struct APIResponse<T: Decodable>: Decodable {
    let status: String
    let data: T
    let message: String?
    let errorCode: String?
    let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case message
        case errorCode = "error_code"
        case timestamp
    }
}
 
// MARK: - Network Error
enum NetworkError: LocalizedError {
    case invalidURL
    case decodingFailed(Error)
    case serverError(Int, String?)
    case unauthorized
    case noConnection
    case custom(String)
 
    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "Invalid URL"
        case .decodingFailed(let e):    return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code, let msg): return "Server error \(code): \(msg ?? "Unknown")"
        case .unauthorized:             return "Unauthorized. Please login again."
        case .noConnection:             return "No internet connection"
        case .custom(let message):      return message
        }
    }
}
 
// MARK: - Auth Models
struct LoginRequest: Encodable {
    let email: String
    let password: String
}
 
struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let name: String
}
 
struct AuthResponse: Decodable {
    let accessToken: String
    let tokenType: String
}
 
// MARK: - Customer Models
struct Customer: Decodable, Identifiable {
    let customerId: Int
    let name: String
    let email: String
    
    var id: Int { customerId }
}
 
struct CreateCustomerRequest: Encodable {
    let name: String
    let email: String
}
 
// MARK: - Account Models
struct Account: Decodable, Identifiable, Hashable {
    let accountId: String
    let balance: Double
    let currency: String
    
    var id: String { accountId }
}
 
struct CreateAccountRequest: Encodable {
    let currency: String
    let initialDeposit: Double
    
    enum CodingKeys: String, CodingKey {
           case currency
           case initialDeposit = "initial_deposit"
       }
}
 
struct BalanceResponse: Decodable {
    let balance: Double
    let currency: String
}
 
// MARK: - Transfer Models
struct TransferRequest: Encodable {
    let fromAccountId: String
    let toAccountId: String
    let transferAmount: Double
}
 
struct TransferResponse: Decodable {
    let id: String
    let fromAccountId: String
    let toAccountId: String
    let amount: Double
    let currency: String
    let createdAt: String

}
 
// MARK: - BIN / Card Info
struct CardBINInfo: Decodable {
    let bin: String
    let brand: String
    let bank: String
    let country: String
    let countryCode: String
    let cardType: String
    let cardLevel: String
 
    var countryFlag: String {
        countryCode.unicodeScalars
            .compactMap { Unicode.Scalar(127397 + $0.value) }
            .map { String($0) }
            .joined()
    }
}

// TopUpRequest
struct TopUpRequest: Encodable {
    let accountId: String
    let amount: Double
    let currency: String = "UAH"
}

// TopUpResponse
struct TopUpResponse: Decodable {
    let balance: Double
    let currency: String
    let message: String?
}


// MARK: - Network Service
final class NetworkService {
    static let shared = NetworkService()
 
//    private let baseURL = "http://localhost:8000"
    private let baseURL = "https://banking-api-production-bb1f.up.railway.app"

    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
 
    private init() {}
 
    // MARK: - GET
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try buildRequest(endpoint, body: nil as String?)
        return try await execute(request)
    }
 
    // MARK: - POST
    func post<Body: Encodable, Response: Decodable>(
        _ endpoint: Endpoint,
        body: Body
    ) async throws -> Response {
        let request = try buildRequest(endpoint, body: body)
        return try await execute(request)
    }
 
    // MARK: - Execute
    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        print("📦 Response: \(String(data: data, encoding: .utf8) ?? "nil")")
        try validateResponse(response, data: data)

        if let wrapped = try? decoder.decode(APIResponse<T>.self, from: data) {
            return wrapped.data
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func fetchArray<T: Decodable>(_ endpoint: Endpoint) async throws -> [T] {
        let request = try buildRequest(endpoint, body: nil as String?)
        let (data, response) = try await session.data(for: request)
        print("📦 Response: \(String(data: data, encoding: .utf8) ?? "nil")")
        try validateResponse(response, data: data)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let wrapper = try decoder.decode(APIResponse<[T]>.self, from: data)
            return wrapper.data
        } catch {
            print("❌ Decoding failed: \(error)")
            throw NetworkError.decodingFailed(error)
        }
    }
 
    // MARK: - Build Request
    private func buildRequest<Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body?
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
 
        // Auth token
        if let token = KeychainService.shared.getToken() {
            print("🔑 Token being sent: \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ NO TOKEN IN KEYCHAIN!")
        }
 
        // Body
        if let body {
            request.httpBody = try encoder.encode(body)
        }
 
        return request
    }
 
    // MARK: - Validate Response
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299:
            break
        case 401:
            KeychainService.shared.removeToken()
            throw NetworkError.unauthorized
        default:
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(http.statusCode, message)
        }
    }
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

}
 


// MARK: - Convenience methods
extension NetworkService {
 
    // Auth
    func login(email: String, password: String) async throws -> AuthResponse {
        let response: AuthResponse = try await post(.login, body: LoginRequest(email: email, password: password))
        KeychainService.shared.saveToken(response.accessToken)
        return response
    }
 
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        let response: AuthResponse = try await post(.register, body: RegisterRequest(email: email, password: password, name: name))
        KeychainService.shared.saveToken(response.accessToken)
        return response
    }
 
    func me() async throws -> Customer {
        return try await fetch(.me)
    }
 
    func logout() {
        KeychainService.shared.removeToken()
    }
 
    // Accounts
    func myAccounts() async throws -> [Account] {
        return try await fetch(.myAccounts)
    }
 
    func balance(accountId: String) async throws -> BalanceResponse {
        return try await fetch(.balance(accountId))
    }
 
    func createAccount(currency: String, initialDeposit: Double = 0.0) async throws -> Account {
        let request = CreateAccountRequest(currency: currency, initialDeposit: initialDeposit)
        let response: APIResponse<Account> = try await post(.createAccount, body: request)
        return response.data
    }
 
    // Transfers
    func transfer(from: String, to: String, amount: Double) async throws -> TransferResponse {
        let request = TransferRequest(
            fromAccountId: from,
            toAccountId: to,
            transferAmount: amount
        )
        return try await post(.transfer, body: request)
    }
 
    func transferHistory(accountId: String) async throws -> [TransferResponse] {
        return try await fetch(.accountTransfers(accountId))
    }
 
    // Cards
    func checkCard(_ number: String) async throws -> CardBINInfo {
        return try await fetch(.checkCard(number))
    }
    
    // Top Up
    func topUp(accountId: String, amount: Double) async throws -> TopUpResponse {
        let request = TopUpRequest(accountId: accountId, amount: amount)
        return try await post(.topup, body: request)
    }
}

struct EmptyResponse: Decodable {}
