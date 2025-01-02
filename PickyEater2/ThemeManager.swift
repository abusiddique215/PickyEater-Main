import SwiftUI

// Theme environment key
struct ThemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme? = nil
}

// Extend environment values to include theme
extension EnvironmentValues {
    var appTheme: ColorScheme? {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// Theme manager as observable object
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @Published var colorScheme: ColorScheme? = nil
    
    private init() {
        // Initialize the color scheme based on the stored preference
        colorScheme = isDarkMode ? .dark : .light
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        colorScheme = isDarkMode ? .dark : .light
    }
    
    func getCurrentTheme() -> ColorScheme {
        return isDarkMode ? .dark : .light
    }
} 