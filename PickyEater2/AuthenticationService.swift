import LocalAuthentication
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var biometricType: LABiometryType = .none
    @Published var error: Error?
    
    init() {
        getBiometricType()
    }
    
    private func getBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
    
    func authenticate() async {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            await MainActor.run {
                self.error = error
                self.isAuthenticated = false
            }
            return
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your food preferences"
            )
            
            await MainActor.run {
                self.isAuthenticated = success
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isAuthenticated = false
            }
        }
    }
} 