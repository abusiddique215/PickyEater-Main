import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @StateObject private var authService = AuthenticationService()
    @Binding var isAuthenticated: Bool
    
    private let colors = (
        background: Color.black,
        primary: Color(red: 0.98, green: 0.24, blue: 0.25),
        secondary: Color(red: 0.97, green: 0.97, blue: 0.97),
        text: Color.white,
        cardBackground: Color(white: 0.12)
    )
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: authService.biometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 64))
                .foregroundColor(colors.primary)
            
            // Title
            Text("Authentication Required")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colors.text)
            
            // Description
            Text("Please authenticate to access your food preferences")
                .font(.body)
                .foregroundColor(colors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Authenticate Button
            Button {
                Task {
                    await authService.authenticate()
                    isAuthenticated = authService.isAuthenticated
                }
            } label: {
                HStack {
                    Image(systemName: "lock.open.fill")
                    Text("Authenticate")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if let error = authService.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
} 