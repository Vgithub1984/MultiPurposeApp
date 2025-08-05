import SwiftUI

// MARK: - View Extensions
extension View {
    
    // MARK: - Card Styling
    /// Applies the standard card style used throughout the app
    func appCardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Applies a subtle card style for secondary content
    func subtleCardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    // MARK: - Text Styling
    /// Applies the standard title style
    func titleStyle() -> some View {
        self
            .font(.title)
            .bold()
            .foregroundColor(.primary)
    }
    
    /// Applies the standard subtitle style
    func subtitleStyle() -> some View {
        self
            .font(.title2)
            .foregroundColor(.secondary)
    }
    
    /// Applies the standard body text style
    func bodyStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.primary)
    }
    
    /// Applies the standard caption style
    func captionStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    // MARK: - Button Styling
    /// Applies the primary button style
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .background(Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.headline)
    }
    
    /// Applies the secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .padding()
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(10)
            .font(.headline)
    }
    
    // MARK: - Layout Modifiers
    /// Centers the view horizontally
    func centerHorizontally() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    /// Centers the view vertically
    func centerVertically() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .center)
    }
    
    /// Centers the view both horizontally and vertically
    func centerBoth() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: - Spacing Modifiers
    /// Adds standard horizontal padding
    func standardHorizontalPadding() -> some View {
        self
            .padding(.horizontal, 16)
    }
    
    /// Adds standard vertical padding
    func standardVerticalPadding() -> some View {
        self
            .padding(.vertical, 12)
    }
    
    /// Adds standard padding
    func standardPadding() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
    
    // MARK: - Animation Modifiers
    /// Applies standard animation for transitions
    func standardAnimation() -> some View {
        self
            .animation(.easeInOut(duration: 0.3), value: true)
    }
    
    /// Applies quick animation for button presses
    func quickAnimation() -> some View {
        self
            .animation(.easeInOut(duration: 0.1), value: true)
    }
    
    // MARK: - Accessibility
    /// Adds accessibility label and hint
    func accessibilityInfo(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
    }
    
    // MARK: - Conditional Modifiers
    /// Applies a modifier conditionally
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview Extensions
extension View {
    /// Adds preview support for different devices
    func previewDevices() -> some View {
        self
            .previewDevice(PreviewDevice(rawValue: "iPhone 15"))
            .previewDisplayName("iPhone 15")
    }
    
    /// Adds preview support for dark mode
    func previewDarkMode() -> some View {
        self
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
} 

// MARK: - Scroll Behavior with Blur Effect
struct ScrollBlurModifier: ViewModifier {
    @State private var scrollOffset: CGFloat = 0
    let blurRadius: CGFloat
    let blurThreshold: CGFloat
    
    init(blurRadius: CGFloat = 10, blurThreshold: CGFloat = 50) {
        self.blurRadius = blurRadius
        self.blurThreshold = blurThreshold
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .overlay(
                VStack {
                    // Top blur overlay - only show when actually scrolling
                    if scrollOffset < 0 {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .blur(radius: blurRadius)
                            .frame(height: min(blurThreshold, abs(scrollOffset)))
                            .opacity(min(1.0, abs(scrollOffset) / blurThreshold))
                            .allowsHitTesting(false)
                    }
                    
                    Spacer()
                }
            )
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Enhanced Scroll View with Blur
struct ScrollViewWithBlur<Content: View>: View {
    let content: Content
    let blurRadius: CGFloat
    let blurThreshold: CGFloat
    let showsIndicators: Bool
    
    init(
        blurRadius: CGFloat = 10,
        blurThreshold: CGFloat = 50,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.blurRadius = blurRadius
        self.blurThreshold = blurThreshold
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            content
                .coordinateSpace(name: "scroll")
        }
        .modifier(ScrollBlurModifier(blurRadius: blurRadius, blurThreshold: blurThreshold))
    }
}

// MARK: - View Extension for Easy Application
extension View {
    /// Applies scroll blur effect to make top content clearly visible when scrolling
    /// - Parameters:
    ///   - blurRadius: The radius of the blur effect (default: 10)
    ///   - blurThreshold: The scroll distance before blur starts (default: 50)
    /// - Returns: A view with scroll blur behavior
    func scrollBlur(blurRadius: CGFloat = 10, blurThreshold: CGFloat = 50) -> some View {
        self.modifier(ScrollBlurModifier(blurRadius: blurRadius, blurThreshold: blurThreshold))
    }
} 