//
//  CVVTimerView.swift
//  bankApp
//
//  Created by Igor Matsepura on 11.06.2026.
//

import SwiftUI
import Combine

struct CVVTimerView: View {
    @State private var code: String = CVVTimerView.generateCode()
    @State private var progress: CGFloat = 0.0
    @State private var timeLeft: Int = 180
    private let duration = 180
    @State private var isActive = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: AnyCancellable?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text("CVV")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 16) {
                ZStack(alignment: .center) {
                    Circle()
                        .stroke(.white.opacity(0.15), lineWidth: 2.5)
                    
                    Circle()
//                        .trim(from: 0, to: progress)
                        .trim(from: 0, to: 1.0)
                        .stroke(
                            progressColor,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    VStack {
                        Text(timeString)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.black)
                        Text("хв")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.black)
                    }
                }
                .frame(width: 42, height: 42)
                .frame(maxHeight: .infinity, alignment: .center)
                .offset(x: 5, y: -5)
                // Крапки — замаскований CVV
                VStack(spacing: 5) {
                    ForEach(0..<3) { _ in
                        HStack(spacing: 5) {
                            ForEach(0..<6) { _ in
                                Circle()
                                    .fill(Color.gray.opacity(0.35))
                                    .frame(width: 5, height: 5)
                            }
                        }
                    }
                }
                .offset( y: -7)
                // Код
                Text(code)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        
        .frame(width: 180, height: 60)
        .padding(5)
        
        .onReceive(timer) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
                progress = 1.0 - (CGFloat(timeLeft) / CGFloat(duration))
            } else {
                withAnimation(.easeInOut(duration: 0.4)) {
                    code = CVVTimerView.generateCode()
                }
                timeLeft = duration
                progress = 0.0
            }
        }
        .onAppear {
            timerCancellable = timer.connect() as? AnyCancellable
        }
        .onDisappear {
            timerCancellable?.cancel()
            timerCancellable = nil
        }
    
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#D8D8DE").opacity(0.6))
        )
   
       
    }

    
    private var progressColor: Color {
        if progress < 0.5 {
            return .green
        } else if progress < 0.8 {
            return .orange
        } else {
            return .red        }
    }

    private var timeString: String {
        let m = timeLeft / 60
        let s = timeLeft % 60
        return "\(m):\(String(format: "%02d", s))"
    }

    static func generateCode() -> String {
        String(format: "%03d", Int.random(in: 100...999))
    }
}

#Preview {
    CVVTimerView()
}
