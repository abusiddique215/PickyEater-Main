import Foundation
import SwiftData

@MainActor
public final class AuthenticationService: ObservableObject {
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?
    
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func signInWithApple(
        userId: String,
        email: String?,
        fullName: String?
    ) {
        let user = User(
            id: userId,
            email: email ?? "",
            name: fullName ?? "Guest",
            preferences: UserPreferences()
        )
        currentUser = user
        modelContext.insert(user)
        try? modelContext.save()
        isAuthenticated = true
    }
    
    public func signInAsGuest() {
        let user = User(
            id: UUID().uuidString,
            email: "guest@pickyeater.app",
            name: "Guest",
            preferences: UserPreferences()
        )
        currentUser = user
        modelContext.insert(user)
        try? modelContext.save()
        isAuthenticated = true
    }
    
    public func signOut() {
        if let user = currentUser {
            modelContext.delete(user)
            try? modelContext.save()
        }
        currentUser = nil
        isAuthenticated = false
    }
}
