import Foundation

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?

    private init() {
        // Private initializer to enforce singleton pattern
    }

    func signIn(completion: @escaping (Bool) -> Void) {
        // Implement sign in logic
        completion(true)
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }
}
