import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    let colors: (
        background: Color,
        primary: Color,
        secondary: Color,
        text: Color,
        cardBackground: Color,
        searchBackground: Color
    )
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colors.secondary)
                
                TextField("Search for restaurants", text: $text)
                    .foregroundColor(colors.text)
                    .submitLabel(.search)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(colors.secondary)
                    }
                }
            }
            .padding(10)
            .background(colors.searchBackground)
            .cornerRadius(10)
        }
    }
} 