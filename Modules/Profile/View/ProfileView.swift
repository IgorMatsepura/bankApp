//
//  ProfileView.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import SwiftUI
import PhotosUI
import LocalAuthentication

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var tabCoordinator: TabCoordinator  
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotosPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showChangePassword = false
//    @State private var colorScheme: ProfileViewModel.AppColorScheme = .dark
    
    var body: some View {
        ZStack {
            
            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    settingsSection
                    logoutButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    tabCoordinator.popToRootCards() 
                }
                .foregroundStyle(Color(hex: "00C853"))
            }
        }
        .task { await viewModel.loadUser() }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.saveAvatar(image)
                }
            }
        }
//        .preferredColorScheme(viewModel.colorScheme.colorScheme)
        
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(spacing: 16) {
            Button {
                showPhotosPicker = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    if let image = viewModel.avatarImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "00C853").opacity(0.15))
                                .frame(width: 90, height: 90)
                            Text(initials)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(Color(hex: "00C853"))
                        }
                    }
 
                    ZStack {
                        Circle()
                            .fill(Color(hex: "00C853"))
                            .frame(width: 26, height: 26)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.black)
                    }
                }
            }
 
            VStack(spacing: 4) {
                Text(viewModel.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                Text(viewModel.email)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
 
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 1) {
            // Face ID
            SettingsRow(
                icon: "faceid",
                iconColor: Color(hex: "00C853"),
                title: "Face ID"
            ) {
                Toggle("", isOn: $viewModel.isFaceIDEnabled)
                    .tint(Color(hex: "00C853"))
                    .onChange(of: viewModel.isFaceIDEnabled) { _, _ in
                        viewModel.toggleFaceID()
                    }
            }
 
            SettingsRow(
                icon: "lock.fill",
                iconColor: Color(hex: "00C853"),
                title: "Change Password"
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .onTapGesture { showChangePassword = true }
            .navigationDestination(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
 
            SettingsRow(
                icon: "globe",
                iconColor: Color(hex: "00C853"),
                title: "Language"
            ) {
                Picker("", selection: $viewModel.selectedLanguage) {
                    ForEach(viewModel.languages, id: \.self) { lang in
                        Text(lang).tag(lang)
                    }
                }
                .tint(.white.opacity(0.5))
            }
 
            SettingsRow(
                icon: "moon.fill",
                iconColor: Color(hex: "00C853"),
                title: "Theme"
            ) {
                Picker("", selection: $viewModel.colorScheme) {
                    ForEach(ProfileViewModel.AppColorScheme.allCases, id: \.self) { scheme in
                        Text(scheme.rawValue).tag(scheme)
                    }
                }
                .tint(.white.opacity(0.5))
                .onChange(of: viewModel.colorScheme) { _, _ in }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
 
    // MARK: - Logout
    private var logoutButton: some View {
        Button {
            appCoordinator.logout()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Logout")
                    .fontWeight(.medium)
            }
            .foregroundStyle(Color(hex: "00C853"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
 
    private var initials: String {
        viewModel.name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }
}
 
// MARK: - SettingsRow
struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    @ViewBuilder let trailing: () -> Trailing
 
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }
 
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.white)
 
            Spacer()
 
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}



// MARK: - ChangePasswordView
struct ChangePasswordView: View {
   @Environment(\.dismiss) private var dismiss
   @State private var currentPassword = ""
   @State private var newPassword = ""
   @State private var confirmPassword = ""
   @State private var isLoading = false
   @State private var error: String?
   @State private var isSuccess = false

   var isFormValid: Bool {
       !currentPassword.isEmpty &&
       newPassword.count >= 6 &&
       newPassword == confirmPassword
   }

   var body: some View {
       ZStack {
           Color(hex: "0A0A0F").ignoresSafeArea()

           VStack(spacing: 16) {
               AuthTextField(placeholder: "Current password", icon: "lock", text: $currentPassword, isSecure: true)
               AuthTextField(placeholder: "New password", icon: "lock.fill", text: $newPassword, isSecure: true)
               AuthTextField(placeholder: "Confirm password", icon: "checkmark.shield", text: $confirmPassword, isSecure: true)

               if let error {
                   Text(error)
                       .font(.caption)
                       .foregroundStyle(.red)
                       .frame(maxWidth: .infinity, alignment: .leading)
               }

               if newPassword != confirmPassword && !confirmPassword.isEmpty {
                   Text("Passwords don't match")
                       .font(.caption)
                       .foregroundStyle(.red)
                       .frame(maxWidth: .infinity, alignment: .leading)
               }

               Spacer()

               Button {
                   // TODO: change password API
                   isSuccess = true
                   dismiss()
               } label: {
                   Text(isLoading ? "" : "Change Password")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundStyle(.black)
                       .frame(maxWidth: .infinity)
                       .frame(height: 54)
                       .background(isFormValid ? Color(hex: "00C853") : Color(hex: "00C853").opacity(0.4))
                       .clipShape(RoundedRectangle(cornerRadius: 16))
               }
               .disabled(!isFormValid || isLoading)
           }
           .padding(.horizontal, 24)
           .padding(.top, 20)
       }
       .navigationTitle("Change Password")
       .navigationBarTitleDisplayMode(.inline)
   }
}

// MARK: - UserAvatarButton
struct UserAvatarButton: View {
   var onTap: (() -> Void)?

   private var avatarImage: UIImage? {
       if let data = UserDefaults.standard.data(forKey: "user_avatar"),
          let image = UIImage(data: data) {
           return image
       }
       return nil
   }

   private var initials: String {
       return "I"
   }

   var body: some View {
       Button { onTap?() } label: {
           ZStack {
               if let image = avatarImage {
                   Image(uiImage: image)
                       .resizable()
                       .scaledToFill()
                       .frame(width: 32, height: 32)
                       .clipShape(Circle())
               } else {
                   Circle()
                       .fill(Color(hex: "00C853").opacity(0.2))
                       .frame(width: 32, height: 32)
                   Text(initials)
                       .font(.system(size: 12, weight: .semibold))
                       .foregroundStyle(Color(hex: "00C853"))
               }
           }
       }
   }
}



#Preview {
   ProfileView()
       .environmentObject(AppCoordinator())
       .environmentObject(TabCoordinator())
}



// MARK: - AuthTextField
struct AuthTextField: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundStyle(.white)
                    .tint(Color(hex: "00C853"))
            } else {
                TextField(placeholder, text: $text)
                    .foregroundStyle(.white)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .tint(Color(hex: "00C853"))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
