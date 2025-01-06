import LocalAuthentication
import SwiftUI

enum AuthenticationError: Error {
    case notAvailable
    case failed(String)
    case cancelled
    case denied
    
    var localizedDescription: String {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available"
        case .failed(let message):
            return message
        case .cancelled:
            return "Authentication was cancelled"
        case .denied:
            return "Authentication was denied"
        }
    }
}

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    private let context = LAContext()
    
    var biometricType: String {
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "None"
        }
    }
    
    func authenticate() async throws {
        // Reset context for each authentication attempt
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthenticationError.notAvailable
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your preferences"
            )
            
            if success {
                await MainActor.run {
                    self.isAuthenticated = true
                }
            } else {
                throw AuthenticationError.failed("Authentication failed")
            }
        } catch let error as LAError {
            switch error.code {
            case .userCancel:
                throw AuthenticationError.cancelled
            case .userFallback:
                throw AuthenticationError.cancelled
            case .biometryNotAvailable:
                throw AuthenticationError.notAvailable
            case .biometryNotEnrolled:
                throw AuthenticationError.notAvailable
            case .biometryLockout:
                throw AuthenticationError.denied
            default:
                throw AuthenticationError.failed(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        isAuthenticated = false
    }
} 