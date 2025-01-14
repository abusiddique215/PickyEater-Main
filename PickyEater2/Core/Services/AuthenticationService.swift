import AuthenticationServices
import Foundation

public final class AuthenticationService: ObservableObject {
    public static let shared = AuthenticationService()

    @Published public var isAuthenticated = false
    @Published public var currentUser: User?

    public init() {}

    public func signInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }

        // Here you would typically:
        // 1. Validate the credential with your backend
        // 2. Create or fetch a user account
        // 3. Set up the user session
        
        // For now, we'll just create a basic user
        if let email = appleIDCredential.email,
           let fullName = appleIDCredential.fullName {
            currentUser = User(
                id: appleIDCredential.user,
                email: email,
                firstName: fullName.givenName ?? "",
                lastName: fullName.familyName ?? ""
            )
        }
        
        isAuthenticated = true
    }

    public func signInAsGuest() {
        currentUser = nil
        isAuthenticated = true
    }

    public func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}

public enum AuthError: LocalizedError {
    case invalidCredential
    case networkError
    case serverError
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credentials provided"
        case .networkError:
            return "Network error occurred"
        case .serverError:
            return "Server error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
