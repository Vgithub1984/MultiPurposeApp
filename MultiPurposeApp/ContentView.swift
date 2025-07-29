//
//  ContentView.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/28/25.
//

import SwiftUI
import SwiftData

struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .blur(radius: configuration.isPressed ? 4 : 1)
                        .shadow(color: Color.blue.opacity(0.2), radius: 14, x: 0, y: 4)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.7), Color.blue.opacity(0.5), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(configuration.isPressed ? 0.06 : 0.13), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ContentView: View {
    
    var body: some View {
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.5),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all) // This makes it truly full screen
            
            VStack {
                
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 100))
                
                Text("")
                Text("MultiPurposeApp")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features")
                        .font(.title2)
                        .bold()
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Secure and Reliable")
                    }
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Highly Customizable")
                    }
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Fast Performance")
                    }
                }
                
                Spacer()
                
                Button("Get Started") { }
                    .buttonStyle(LiquidGlassButtonStyle())
                
            }
            .padding(.top, 50)
        }
        
    // end of var body: some view
    }
    
// end of ContentView view. Ending point
}



#Preview {
    ContentView()
        
}

