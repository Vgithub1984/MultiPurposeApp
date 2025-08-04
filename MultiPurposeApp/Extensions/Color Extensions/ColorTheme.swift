import SwiftUI

// MARK: - Color Theme System
struct ColorTheme {
    
    // MARK: - Primary Colors
    static let primary = Color.blue
    static let secondary = Color.purple
    static let accent = Color.orange
    
    // MARK: - Semantic Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // MARK: - Background Colors
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)
    
    // MARK: - Text Colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    static let quaternaryText = Color(.quaternaryLabel)
    
    // MARK: - Border Colors
    static let border = Color(.separator)
    static let secondaryBorder = Color(.opaqueSeparator)
    
    // MARK: - Card Colors
    static let cardBackground = Color(.systemBackground)
    static let cardBorder = Color(.separator)
    
    // MARK: - Gradient Colors
    static let primaryGradient = LinearGradient(
        colors: [primary.opacity(0.7), secondary.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.7),
            primary.opacity(0.5),
            secondary.opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Status Colors with Dark Mode Adaptation
    static let statusSuccess = Color.green
    static let statusWarning = Color.orange
    static let statusError = Color.red
    static let statusInfo = Color.blue
    
    // MARK: - Interactive Colors
    static let buttonBackground = Color(.systemBlue)
    static let buttonText = Color(.systemBackground)
    static let destructiveButton = Color(.systemRed)
    
    // MARK: - List Colors
    static let listBackground = Color(.systemGroupedBackground)
    static let listRowBackground = Color(.secondarySystemGroupedBackground)
    static let listSeparator = Color(.separator)
    
    // MARK: - Progress Colors
    static let progressBackground = Color(.systemGray5)
    static let progressFill = Color.blue
    
    // MARK: - Custom Opacity Colors
    static func primaryWithOpacity(_ opacity: Double) -> Color {
        return primary.opacity(opacity)
    }
    
    static func secondaryWithOpacity(_ opacity: Double) -> Color {
        return secondary.opacity(opacity)
    }
    
    static func successWithOpacity(_ opacity: Double) -> Color {
        return success.opacity(opacity)
    }
    
    static func errorWithOpacity(_ opacity: Double) -> Color {
        return error.opacity(opacity)
    }
    
    static func warningWithOpacity(_ opacity: Double) -> Color {
        return warning.opacity(opacity)
    }
    
    // MARK: - Dynamic Colors for Dark Mode
    static let dynamicBackground = Color(.systemBackground)
    static let dynamicSecondaryBackground = Color(.secondarySystemBackground)
    static let dynamicText = Color(.label)
    static let dynamicSecondaryText = Color(.secondaryLabel)
    static let dynamicBorder = Color(.separator)
    
    // MARK: - Glass Effect Colors
    static let glassBackground = Color(.systemBackground).opacity(0.8)
    static let glassBorder = Color(.separator).opacity(0.3)
    
    // MARK: - Shadow Colors
    static let shadowColor = Color.black.opacity(0.1)
    static let darkShadowColor = Color.black.opacity(0.2)
    
    // MARK: - Chart Colors
    static let chartColors: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .yellow, .mint, .teal, .indigo
    ]
}

// MARK: - Color Extensions for Dark Mode Compatibility
extension Color {
    
    // MARK: - Semantic Colors
    static let appPrimary = ColorTheme.primary
    static let appSecondary = ColorTheme.secondary
    static let appAccent = ColorTheme.accent
    
    // MARK: - Status Colors
    static let appSuccess = ColorTheme.success
    static let appWarning = ColorTheme.warning
    static let appError = ColorTheme.error
    static let appInfo = ColorTheme.info
    
    // MARK: - Background Colors
    static let appBackground = ColorTheme.background
    static let appSecondaryBackground = ColorTheme.secondaryBackground
    static let appTertiaryBackground = ColorTheme.tertiaryBackground
    static let appGroupedBackground = ColorTheme.groupedBackground
    static let appSecondaryGroupedBackground = ColorTheme.secondaryGroupedBackground
    
    // MARK: - Text Colors
    static let appPrimaryText = ColorTheme.primaryText
    static let appSecondaryText = ColorTheme.secondaryText
    static let appTertiaryText = ColorTheme.tertiaryText
    static let appQuaternaryText = ColorTheme.quaternaryText
    
    // MARK: - Border Colors
    static let appBorder = ColorTheme.border
    static let appSecondaryBorder = ColorTheme.secondaryBorder
    
    // MARK: - Card Colors
    static let appCardBackground = ColorTheme.cardBackground
    static let appCardBorder = ColorTheme.cardBorder
    
    // MARK: - Interactive Colors
    static let appButtonBackground = ColorTheme.buttonBackground
    static let appButtonText = ColorTheme.buttonText
    static let appDestructiveButton = ColorTheme.destructiveButton
    
    // MARK: - List Colors
    static let appListBackground = ColorTheme.listBackground
    static let appListRowBackground = ColorTheme.listRowBackground
    static let appListSeparator = ColorTheme.listSeparator
    
    // MARK: - Progress Colors
    static let appProgressBackground = ColorTheme.progressBackground
    static let appProgressFill = ColorTheme.progressFill
    
    // MARK: - Glass Effect Colors
    static let appGlassBackground = ColorTheme.glassBackground
    static let appGlassBorder = ColorTheme.glassBorder
    
    // MARK: - Shadow Colors
    static let appShadow = ColorTheme.shadowColor
    static let appDarkShadow = ColorTheme.darkShadowColor
}

// MARK: - View Extensions for Dark Mode
extension View {
    
    /// Applies the app's glass effect styling with dark mode support
    func appGlassStyle() -> some View {
        self
            .background(Color.appGlassBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appGlassBorder, lineWidth: 1)
            )
    }
    
    /// Applies the app's standard button styling with dark mode support
    func appButtonStyle() -> some View {
        self
            .background(Color.appButtonBackground)
            .foregroundColor(Color.appButtonText)
            .cornerRadius(22)
    }
    
    /// Applies the app's destructive button styling with dark mode support
    func appDestructiveButtonStyle() -> some View {
        self
            .background(Color.appDestructiveButton)
            .foregroundColor(Color.appButtonText)
            .cornerRadius(22)
    }
} 