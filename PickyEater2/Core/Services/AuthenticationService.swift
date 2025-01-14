import Foundation

public final class AuthenticationService: ObservableObject {
    public static let shared = AuthenticationService()
    
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?
    
    public init() {}
    
    // ... existing code ...
} 