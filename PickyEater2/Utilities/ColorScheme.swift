import SwiftUI

enum AppColors {
    static func background(for colorScheme: ColorScheme?) -> Color {
        colorScheme == .dark ? .black : .white
    }

    static let primary = Color(red: 0.98, green: 0.24, blue: 0.25) // DoorDash red

    static func secondary(for colorScheme: ColorScheme?) -> Color {
        colorScheme == .dark ? Color(white: 0.97) : Color(white: 0.3)
    }

    static func text(for colorScheme: ColorScheme?) -> Color {
        colorScheme == .dark ? .white : .black
    }

    static func cardBackground(for colorScheme: ColorScheme?) -> Color {
        colorScheme == .dark ? Color(white: 0.12) : Color(white: 0.95)
    }
}
