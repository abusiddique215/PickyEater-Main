import AuthenticationServices
import SwiftUI

class SignInWithAppleManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var userIdentifier: String?
    @Published var userName: String?
    @Published var userEmail: String?

    static let shared = SignInWithAppleManager()

    override private init() {
        super.init()
        checkAuthenticationState()
    }

    private func checkAuthenticationState() {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") else {
            return
        }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { [weak self] credentialState, _ in
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    self?.isAuthenticated = true
                    self?.userIdentifier = userIdentifier
                    self?.userName = UserDefaults.standard.string(forKey: "userName")
                    self?.userEmail = UserDefaults.standard.string(forKey: "userEmail")
                case .revoked, .notFound:
                    self?.signOut()
                default:
                    break
                }
            }
        }
    }

    func signIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self

        // Get the window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController
        {
            controller.presentationContextProvider = rootViewController as? ASAuthorizationControllerPresentationContextProviding
        }

        controller.performRequests()
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        isAuthenticated = false
        userIdentifier = nil
        userName = nil
        userEmail = nil
    }
}

extension SignInWithAppleManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        // Store user data
        userIdentifier = credentials.user
        userName = [credentials.fullName?.givenName, credentials.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        userEmail = credentials.email

        // Save to UserDefaults
        UserDefaults.standard.set(credentials.user, forKey: "userIdentifier")
        if !userName!.isEmpty {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
        if let email = credentials.email {
            UserDefaults.standard.set(email, forKey: "userEmail")
        }

        isAuthenticated = true
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
}
