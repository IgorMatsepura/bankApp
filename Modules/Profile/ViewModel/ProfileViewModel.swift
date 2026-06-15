//
//  ProfileViewModel.swift
//  bankApp
//
//  Created by Igor Matsepura on 15.06.2026.
//

import SwiftUI
import PhotosUI
import LocalAuthentication
import Combine

// MARK: - ProfileViewModel
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var avatarImage: UIImage?
    @Published var isFaceIDEnabled: Bool = false
    @Published var selectedLanguage: String = "English"
    @Published var colorScheme: AppColorScheme = .light
    @Published var isLoading = false
    @Published var error: String?
 
    private let network = NetworkService.shared
    private let avatarKey = "user_avatar"
    private let faceIDKey = "face_id_enabled"
 
    let languages = ["English", "Ukrainian"]
 
    enum AppColorScheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
 
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
 
    init() {
        isFaceIDEnabled = UserDefaults.standard.bool(forKey: faceIDKey)
        loadAvatar()
    }
 
    func loadUser() async {
        do {
            let customer = try await network.me()
            name = customer.name
            email = customer.email
        } catch {
            self.error = error.localizedDescription
        }
    }
 
    func toggleFaceID() {
        isFaceIDEnabled.toggle()
        UserDefaults.standard.set(isFaceIDEnabled, forKey: faceIDKey)
 
        if isFaceIDEnabled {
            authenticateFaceID()
        }
    }
 
    private func authenticateFaceID() {
        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Enable Face ID for Kinect Bank"
        ) { success, _ in
            DispatchQueue.main.async {
                if !success {
                    self.isFaceIDEnabled = false
                    UserDefaults.standard.set(false, forKey: self.faceIDKey)
                }
            }
        }
    }
 
    func saveAvatar(_ image: UIImage) {
        avatarImage = image
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: avatarKey)
        }
    }
 
    private func loadAvatar() {
        if let data = UserDefaults.standard.data(forKey: avatarKey),
           let image = UIImage(data: data) {
            avatarImage = image
        }
    }
}
