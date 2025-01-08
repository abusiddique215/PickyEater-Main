import AuthenticationServices
import Foundation
import SwiftUI

@MainActor
class AuthenticationService: NSObject, ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authError: Error?
    
    private override init() {
        super.init()
        checkAuthenticationState()
    }
    
    func checkAuthenticationState() {
        // Check keychain for stored credentials
        if let userData = KeychainManager.shared.loadUser() {
            self.currentUser = userData
            self.isAuthenticated = true
        }
    }
    
    func signInWithApple() async throws {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let result = try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = SignInWithAppleDelegate(continuation: continuation)
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
        }
        
        guard let appleIDCredential = result as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }
        
        // Create user from Apple ID credential
        let user = User(
            id: appleIDCredential.user,
            name: [
                appleIDCredential.fullName?.givenName,
                appleIDCredential.fullName?.familyName
            ].compactMap { $0 }.joined(separator: " "),
            email: appleIDCredential.email ?? ""
        )
        
        // Store user data securely
        try KeychainManager.shared.saveUser(user)
        
        self.currentUser = user
        self.isAuthenticated = true
    }
    
    func signOut() {
        KeychainManager.shared.deleteUser()
        self.currentUser = nil
        self.isAuthenticated = false
    }
}

// MARK: - Helper Types

struct User: Codable {
    let id: String
    let name: String
    let email: String
}

enum AuthError: Error {
    case invalidCredential
    case signInFailed
    case noUser
    
    var localizedDescription: String {
        switch self {
        case .invalidCredential:
            return "Invalid credentials provided"
        case .signInFailed:
            return "Sign in failed"
        case .noUser:
            return "No user found"
        }
    }
}

// MARK: - Sign in with Apple Delegate

private class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else {
            fatalError("No window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
} 