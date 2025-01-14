import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @StateObject private var authService = AuthenticationService()
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.colorScheme) private var colorScheme

    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25), // DoorDash red
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97), // Light gray
        text: Color.white
    )

    var body: some View {
        ZStack {
            // Background
            colors.background.ignoresSafeArea()

            VStack(spacing: 32) {
                // Logo and Welcome Text
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(colors.primary)

                    Text("Welcome to PickyEater")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colors.text)

                    Text("Find your perfect meal")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(colors.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // Sign in Options
                VStack(spacing: 20) {
                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        Task {
                            do {
                                // Handle sign in completion
                                showError = false
                            } catch {
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .frame(height: 44)

                    // Continue as Guest
                    Button {
                        // Handle guest sign in
                    } label: {
                        Text("Continue as Guest")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(colors.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colors.secondary, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AuthenticationView()
}
