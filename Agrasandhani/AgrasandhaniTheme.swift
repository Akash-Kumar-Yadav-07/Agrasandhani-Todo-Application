//
//  AgrasandhaniTheme.swift
//  Agrasandhani
//
//  Created by Akash Kumar Yadav on 13/09/25.
//

import SwiftUI

// MARK: - Theme Manager (Centralized)
class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true {
        didSet {
            objectWillChange.send()
        }
    }
    
    static let shared = ThemeManager()
    private init() {}
}

// MARK: - Agrasandhani Divine Theme
struct AgrasandhaniTheme {
    
    // MARK: - Theme Mode (Using centralized manager)
    static var isDarkMode: Bool {
        get { ThemeManager.shared.isDarkMode }
        set { ThemeManager.shared.isDarkMode = newValue }
    }
    
    // MARK: - Colors
    struct Colors {
        // Dark Mode - Darkness of Bad Records with Divine Light
        private static let darkCosmicVoid = Color(red: 0.02, green: 0.02, blue: 0.05)     // Deep void black
        private static let darkCharcoalAbyss = Color(red: 0.08, green: 0.08, blue: 0.12)  // Charcoal abyss
        private static let darkMidnightShadow = Color(red: 0.12, green: 0.12, blue: 0.18) // Midnight shadow
        private static let darkDivineGold = Color(red: 1.0, green: 0.84, blue: 0.0)      // Bright divine gold
        private static let darkEtherealSilver = Color(red: 0.9, green: 0.9, blue: 0.95)   // Ethereal silver
        private static let darkMysticPurple = Color(red: 0.4, green: 0.2, blue: 0.6)     // Mystic purple
        private static let darkEmberOrange = Color(red: 1.0, green: 0.5, blue: 0.0)      // Ember orange
        
        // Light Mode - Original Divine Theme
        private static let lightCosmicBlue = Color(red: 0.90, green: 0.93, blue: 0.99)   // Light cosmic blue
        private static let lightDivineGold = Color(red: 0.85, green: 0.65, blue: 0.13)   // Warm gold
        private static let lightPureWhite = Color.white
        private static let lightSilverMist = Color(red: 0.75, green: 0.75, blue: 0.75)   // Silver
        private static let lightParchmentBackground = Color(red: 0.98, green: 0.96, blue: 0.91) // Warm parchment
        private static let lightInkBlack = Color(red: 0.15, green: 0.15, blue: 0.15)     // Soft black for text
        
        // Dynamic Colors Based on Mode
        static var primaryBackground: Color {
            isDarkMode ? darkCosmicVoid : lightParchmentBackground
        }
        
        static var secondaryBackground: Color {
            isDarkMode ? darkCharcoalAbyss : lightPureWhite
        }
        
        static var cardBackground: Color {
            isDarkMode ? darkMidnightShadow : lightPureWhite
        }
        
        static var divineAccent: Color {
            isDarkMode ? darkDivineGold : lightDivineGold
        }
        
        static var primaryText: Color {
            isDarkMode ? darkEtherealSilver : lightInkBlack
        }
        
        static var secondaryText: Color {
            isDarkMode ? Color(red: 0.7, green: 0.7, blue: 0.8) : lightInkBlack
        }
        
        static var accentText: Color {
            isDarkMode ? darkDivineGold : lightDivineGold
        }
        
        // Functional colors (same for both modes)
        static let completedGreen = Color(red: 0.2, green: 0.8, blue: 0.4)   // Brighter completion green
        static let warningAmber = Color(red: 0.92, green: 0.68, blue: 0.13)  // Warning amber
        static let criticalRed = Color(red: 0.9, green: 0.2, blue: 0.2)      // Critical red
        
        // Dark mode specific colors
        static var shadowColor: Color {
            isDarkMode ? Color.black.opacity(0.6) : Color.black.opacity(0.1)
        }
        
        static var glowColor: Color {
            isDarkMode ? darkDivineGold.opacity(0.3) : lightDivineGold.opacity(0.2)
        }
        
        // Gradient colors
        static var divineGradient: LinearGradient {
            if isDarkMode {
                return LinearGradient(
                    gradient: Gradient(colors: [
                        darkCosmicVoid,
                        darkCharcoalAbyss,
                        darkMidnightShadow.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    gradient: Gradient(colors: [lightCosmicBlue, lightDivineGold.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        static var cardGradient: LinearGradient {
            if isDarkMode {
                return LinearGradient(
                    gradient: Gradient(colors: [
                        darkMidnightShadow,
                        darkCharcoalAbyss.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                return LinearGradient(
                    gradient: Gradient(colors: [lightPureWhite, lightPureWhite.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        
        static var completionGradient: LinearGradient {
            return LinearGradient(
                gradient: Gradient(colors: [
                    completedGreen,
                    completedGreen.opacity(0.6),
                    isDarkMode ? darkMysticPurple.opacity(0.4) : completedGreen.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        // Motivational colors - Light in the darkness
        static var motivationalAccent: Color {
            isDarkMode ? darkEmberOrange : Color.orange
        }
        
        static var hopeGlow: Color {
            isDarkMode ? Color(red: 0.3, green: 0.8, blue: 1.0) : Color.blue
        }
    }
    
    // MARK: - Typography
    struct Typography {
        static let titleFont = Font.system(size: 24, weight: .bold, design: .serif)
        static let headerFont = Font.system(size: 20, weight: .semibold, design: .serif)
        static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
        static let captionFont = Font.system(size: 14, weight: .medium, design: .default)
        static let smallFont = Font.system(size: 12, weight: .regular, design: .default)
        
        // Divine-inspired font modifiers with reactive theme awareness
        static func divineTitle() -> some ViewModifier {
            return DivineTextModifier(font: titleFont, isDarkMode: ThemeManager.shared.isDarkMode)
        }
        
        static func divineHeader() -> some ViewModifier {
            return DivineTextModifier(font: headerFont, isDarkMode: ThemeManager.shared.isDarkMode)
        }
        
        static func divineBody() -> some ViewModifier {
            return DivineTextModifier(font: bodyFont, isDarkMode: ThemeManager.shared.isDarkMode)
        }
        
        static func motivationalText() -> some ViewModifier {
            return DivineTextModifier(font: captionFont, isDarkMode: ThemeManager.shared.isDarkMode)
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let full: CGFloat = 50
    }
    
    // MARK: - Shadows & Effects
    struct Shadows {
        static var soft: Color {
            Colors.shadowColor
        }
        
        static var medium: Color {
            isDarkMode ? Color.black.opacity(0.8) : Color.black.opacity(0.2)
        }
        
        static var strong: Color {
            isDarkMode ? Color.black.opacity(0.9) : Color.black.opacity(0.3)
        }
        
        static func divineShadow() -> some ViewModifier {
            return DivineShadowModifier()
        }
        
        static func darkModeGlow() -> some ViewModifier {
            return DarkModeGlowModifier()
        }
        
        static func motivationalGlow() -> some ViewModifier {
            return MotivationalGlowModifier()
        }
    }
    
    // MARK: - Animations
    struct Animations {
        static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let smoothEase = Animation.easeInOut(duration: 0.4)
        static let gentleFloat = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let inkFlow = Animation.easeOut(duration: 0.6)
    }
}

// MARK: - Custom View Modifiers
struct DivineTextModifier: ViewModifier {
    let font: Font
    let isDarkMode: Bool
    
    private var textColor: Color {
        isDarkMode ? 
            Color(red: 0.9, green: 0.9, blue: 0.95) : // darkEtherealSilver
            Color(red: 0.15, green: 0.15, blue: 0.15) // lightInkBlack
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(textColor)
    }
}

struct DivineShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: AgrasandhaniTheme.Shadows.soft, radius: 4, x: 0, y: 2)
            .shadow(color: AgrasandhaniTheme.Shadows.medium, radius: 1, x: 0, y: 1)
    }
}

struct DarkModeGlowModifier: ViewModifier {
    func body(content: Content) -> some View {
        if AgrasandhaniTheme.isDarkMode {
            content
                .shadow(color: AgrasandhaniTheme.Colors.glowColor, radius: 6, x: 0, y: 0)
                .shadow(color: AgrasandhaniTheme.Colors.divineAccent.opacity(0.1), radius: 12, x: 0, y: 0)
        } else {
            content
                .shadow(color: AgrasandhaniTheme.Colors.glowColor, radius: 2, x: 0, y: 1)
        }
    }
}

struct MotivationalGlowModifier: ViewModifier {
    func body(content: Content) -> some View {
        if AgrasandhaniTheme.isDarkMode {
            content
                .shadow(color: AgrasandhaniTheme.Colors.motivationalAccent.opacity(0.6), radius: 8, x: 0, y: 0)
                .shadow(color: AgrasandhaniTheme.Colors.hopeGlow.opacity(0.3), radius: 16, x: 0, y: 0)
        } else {
            content
                .shadow(color: AgrasandhaniTheme.Colors.motivationalAccent.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
}

struct DivineCardModifier: ViewModifier {
    let isCompleted: Bool
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    private var cardBackgroundColor: Color {
        if isCompleted {
            return AgrasandhaniTheme.Colors.completedGreen.opacity(0.1)
        } else {
            // Directly use theme manager state for immediate reactivity
            return isDarkMode ? 
                Color(red: 0.12, green: 0.12, blue: 0.18) : // darkMidnightShadow
                Color.white // lightPureWhite
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                    .fill(cardBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                    .stroke(
                        isCompleted ? 
                        AgrasandhaniTheme.Colors.completedGreen : 
                        AgrasandhaniTheme.Colors.divineAccent.opacity(0.3),
                        lineWidth: isDarkMode ? 1.5 : 1
                    )
            )
            .divineShadow()
            .if(isDarkMode) { view in
                view.darkModeGlow()
            }
    }
}

// MARK: - View Extensions
extension View {
    func divineTitle() -> some View {
        modifier(AgrasandhaniTheme.Typography.divineTitle())
    }
    
    func divineHeader() -> some View {
        modifier(AgrasandhaniTheme.Typography.divineHeader())
    }
    
    func divineBody() -> some View {
        modifier(AgrasandhaniTheme.Typography.divineBody())
    }
    
    func motivationalText() -> some View {
        modifier(AgrasandhaniTheme.Typography.motivationalText())
    }
    
    func divineShadow() -> some View {
        modifier(AgrasandhaniTheme.Shadows.divineShadow())
    }
    
    func darkModeGlow() -> some View {
        modifier(AgrasandhaniTheme.Shadows.darkModeGlow())
    }
    
    func motivationalGlow() -> some View {
        modifier(AgrasandhaniTheme.Shadows.motivationalGlow())
    }
    
    func divineCard(isCompleted: Bool = false) -> some View {
        modifier(DivineCardModifier(isCompleted: isCompleted))
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}