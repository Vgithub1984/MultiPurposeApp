import SwiftUI

struct LoggingInView: View {
    @State private var animate = false
    @State private var walkOffset: CGFloat = -120
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 20) {
      
                GeometryReader { geometry in
                    Image(systemName: "figure.walk.motion")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.green)
                        .offset(x: walkOffset)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false), value: animate)
                        .onAppear {
                            animate = true
                            withAnimation(.linear(duration: 8.0)) {
                                walkOffset = geometry.size.width - 90 + 120
                            }
                        }
                }
                .frame(height: 90)
                Text("")
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.7)
                Text("")
                Text("Hold tight...")
                    .font(.title2)
                Text("You are being logged into an Awesome App")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
        }
        //.onAppear { animate = true } // Moved animate = true into GeometryReader's onAppear
    }
}

#Preview {
    LoggingInView()
}
