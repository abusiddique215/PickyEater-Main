import SwiftUI

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