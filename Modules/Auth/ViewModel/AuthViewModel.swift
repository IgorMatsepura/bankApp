//
//  AuthViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 12.06.2026.
//

import SwiftUI
import Combine


// MARK: - AuthViewModel
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = "test@railway.com"
    @Published var password = "123456"
    @Published var name = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var hasError = false

    @Published var isRegistering = false
 
//    var onSuccess: (() -> Void)?
    @Published var isAuthenticated = false
    private let network = NetworkService.shared
 
    var isFormValid: Bool {
        if isRegistering {
            return !name.isEmpty && isValidEmail && isValidPassword
        }
        return isValidEmail && isValidPassword
    }
 
    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }
 
    private var isValidPassword: Bool {
        password.count >= 6
    }
 
    func login() async {
        isLoading = true
        print("🟢 Login started, isLoading: \(isLoading)")
        defer {
            isLoading = false
            print("🔴 Login finished, isLoading: \(isLoading)")
        }
        
        do {
            let response = try await network.login(email: email, password: password)
            print("✅ Login success, token: \(response.accessToken.prefix(20))...")
            KeychainService.shared.saveToken(response.accessToken)
            isAuthenticated = true
        } catch {
            print("❌ Login error: \(error)")
            self.error = error.localizedDescription
            self.hasError = true
            isAuthenticated = false
        }
    }
 
    func register() async {
        isLoading = true
        defer { isLoading = false }
        error = nil
        hasError = false
        
        do {
            // 1. Реєстрація
            let _ = try await network.register(name: name, email: email, password: password)
            
            // 2. Логін
            let loginResponse = try await network.login(email: email, password: password)
            
            // 3. Збереження токена
            KeychainService.shared.saveToken(loginResponse.accessToken)
            
            // 4. Перехід на головний екран
            isAuthenticated = true
            
        } catch {
            self.error = error.localizedDescription
            self.hasError = true
            isAuthenticated = false
        }
    }
    
    
    func submit() async {
        if isRegistering {
            await register()
        } else {
            await login()
        }
    }
 
    func toggleMode() {
        withAnimation {
            isRegistering.toggle()
            error = nil
        }
    }
    
    //MARK: checked status auth
    func checkAuthStatus() async {
        guard KeychainService.shared.getToken() != nil else {
            isAuthenticated = false
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let _ = try await network.me()
            isAuthenticated = true
        } catch {
            
            KeychainService.shared.removeToken()
            isAuthenticated = false
        }
    }
    
    func loginWithBiometrics() async {
        guard let savedEmail = UserDefaults.standard.string(forKey: "saved_email"),
              let savedPassword = UserDefaults.standard.string(forKey: "saved_password") else {
            error = "Please login with password first"
            hasError = true
            return
        }
        
        email = savedEmail
        password = savedPassword
        await login()
    }
    
    func logout() {
         KeychainService.shared.removeToken()
         isAuthenticated = false
     }
}

