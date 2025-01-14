import AuthenticationServices
import PickyEater2Core
import SwiftUI

@MainActor
class SignInWithAppleManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var error: Error?

    private let authService: AuthenticationService

    init(authService: AuthenticationService = AuthenticationService()) {
        self.authService = authService
        super.init()
    }

    func signIn() async throws {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let result = try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()

            // Store continuation to be used in delegate methods
            self.signInContinuation = continuation
        }

        // Handle the result
        switch result {
        case let .success(authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Process the credential
                isSignedIn = true
            }
        case let .failure(error):
            throw error
        }
    }

    private var signInContinuation: CheckedContinuation<Result<ASAuthorization, Error>, Error>?
}

extension SignInWithAppleManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        signInContinuation?.resume(returning: .success(authorization))
        signInContinuation = nil
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        signInContinuation?.resume(throwing: error)
        signInContinuation = nil
    }
}

extension SignInWithAppleManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else {
            fatalError("No window found")
        }
        return window
    }
}
