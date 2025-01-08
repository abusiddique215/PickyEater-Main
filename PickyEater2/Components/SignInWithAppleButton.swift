import AuthenticationServices
import SwiftUI

struct SignInWithAppleButton: View {
    @StateObject private var signInManager = SignInWithAppleManager.shared

    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )

    var body: some View {
        Button {
            signInManager.signIn()
        } label: {
            HStack {
                Image(systemName: "apple.logo")
                    .font(.title2)
                Text(signInManager.isAuthenticated ? "Sign Out" : "Sign in with Apple")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.cardBackground)
            .foregroundColor(colors.text)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(colors.primary, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}
