//
//  SplashView.swift
//  bankApp
//
//  Created by Igor Matsepura on 14.06.2026.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var coordinator: AppCoordinator

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
            
            VStack(spacing: 20) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "00C853"))
                
                Text("Kinect Bank")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "00C853")))
                    .scaleEffect(1.2)
                    .padding(.top, 20)
            }
        }
      
    }
}


#Preview {
    SplashView()
}
