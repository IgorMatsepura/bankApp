//
//  AuthView.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI
import LocalAuthentication
import SwiftUI
import LocalAuthentication

struct AuthView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var viewModel: AuthViewModel
    @State private var isBiometricAvailable = false
    @State private var showingFaceIDAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password
    }
    
    var body: some View {
        ZStack {
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
            
            ScrollView {
                VStack(spacing: 30) {
                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "00C853"))
                        
                        Text("Kinect Bank")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 60)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Name Field (only for registration)
                        if viewModel.isRegistering {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("", text: $viewModel.name)
                                    .textFieldStyle(AuthTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .email
                                    }
                            }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("", text: $viewModel.email)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField("", text: $viewModel.password)
                                .textFieldStyle(AuthTextFieldStyle())
                                .focused($focusedField, equals: .password)
                                .submitLabel(.done)
                                .onSubmit {
                                    Task {
                                        await viewModel.submit()
                                    }
                                }
                        }
                        
                        // Password hint
                        if viewModel.isRegistering {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.caption2)
                                Text("Minimum 6 characters")
                                    .font(.caption2)
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Submit Button
                        Button {
                            Task {
                                await viewModel.submit()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(viewModel.isRegistering ? "Create Account" : "Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "00C853"), Color(hex: "00A843")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .opacity(viewModel.isFormValid ? 1 : 0.6)
                        
                        // Face ID Button (only for login)
                        if !viewModel.isRegistering && isBiometricAvailable {
                            Button {
                                authenticateWithBiometrics()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "faceid")
                                        .font(.title3)
                                    Text("Sign in with Face ID")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            }
                        }
                        
                        // Toggle between Login and Register
                        HStack {
                            Text(viewModel.isRegistering ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Button(viewModel.isRegistering ? "Sign In" : "Create Account") {
                                withAnimation {
                                    viewModel.toggleMode()
                                    focusedField = viewModel.isRegistering ? .name : .email
                                }
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "00C853"))
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "Something went wrong")
        }
        .onAppear {
            checkBiometricAvailability()
        }
        .onChange(of: viewModel.isAuthenticated) { _, isAuth in
            print("🔄 isAuthenticated changed to: \(isAuth)")
            if isAuth {
                appCoordinator.showMain()
            }
        }
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login to your bank account") { success, error in
            DispatchQueue.main.async {
                if success {
                    Task {
                        await viewModel.loginWithBiometrics()
                    }
                }
            }
        }
    }
}

// MARK: - AuthTextFieldStyle
struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(.white)
            .accentColor(Color(hex: "00C853"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

#Preview {
    let coordinator = AppCoordinator()
    return AuthView(viewModel: coordinator.authViewModel)
        .environmentObject(coordinator)
}
