# Kinect Bank 💳

A modern banking iOS application built with SwiftUI. This is a pet project demonstrating clean architecture, modern iOS development practices, and integration with a custom banking API.

## 📱 Screenshots

| Login | Cards | Transfer | Profile |
|-------|-------|----------|---------|
| ![Login] 
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-15 at 14 35 09" src="https://github.com/user-attachments/assets/8508fff9-bc10-4ed6-809c-a704f125ed66" />
| ![Cards]| 
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-15 at 14 37 10" src="https://github.com/user-attachments/assets/fed73f3a-575e-41f2-8297-10ab5eac3fc0" />
![Transfer](screenshots/transfer.png) | 
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-15 at 14 37 34" src="https://github.com/user-attachments/assets/006e247b-6399-4f0d-8ccb-8308d40bf011" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-15 at 14 37 26" src="https://github.com/user-attachments/assets/bde087c7-ef13-4699-aadf-bd5a2be08ae0" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-15 at 14 37 17" src="https://github.com/user-attachments/assets/1151e1b4-41b9-4967-90fd-a7b0f279b139" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-06-15 at 14 37 44" src="https://github.com/user-attachments/assets/9cd18cda-a816-49f9-b8ea-3574d121ce48" />

![Profile](screenshots/profile.png) |

## ✨ Features


### 🔐 Authentication
- User registration & login with JWT tokens
- Face ID biometric authentication
- Secure token storage in Keychain
- Auto-login on app restart

### 💳 Cards Management
- Multi-currency cards (UAH, USD, EUR, GBP, PLN)
- Card flip animation (front/back)
- Dynamic CVV display
- Card balance grouping by currency

### 💸 Transfers & Payments
- Transfer between accounts
- Top up card balance
- Transaction history
- Real-time balance updates

### 👤 Profile
- Avatar customization (camera / photo library)
- Change password
- Face ID toggle
- Language switch (English / Українська)
- Dark/Light theme support

### 🛠️ Additional Features
- Exchange rate view
- Scheduled payments
- Credit products showcase
- QR code scanning (coming soon)
- Push notifications (coming soon)

## 🏗️ Architecture

- **MVVM-C** (Model-View-ViewModel-Coordinator)
- **SwiftUI** for UI
- **Combine** for reactive programming
- **Async/await** for networking
- **Keychain** for secure data storage
- **UserDefaults** + **@AppStorage** for settings

## 📁 Project Structure
