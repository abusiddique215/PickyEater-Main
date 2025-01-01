import SwiftUI
import SwiftData

@Observable
class ThemeManager {
    static let shared = ThemeManager()
    private let themeKey = "AppTheme"
    
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
        }
    }
    
    private init() {
        let savedTheme = UserDefaults.standard.string(forKey: themeKey)
        self.currentTheme = AppTheme(rawValue: savedTheme ?? "") ?? .system
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .system
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

struct ThemeModifier: ViewModifier {
    let theme: AppTheme
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(theme.colorScheme)
            .environment(\.appTheme, theme)
    }
} 