import SwiftUI
import AuthenticationServices
import Combine

@MainActor
final class AuthManager: NSObject, ObservableObject {
    @Published var userIdentifier: String?
    @Published var isSignedIn: Bool = false
    @Published var displayName: String = ""
    @Published var error: String?

    private let key = "bot.appleUserIdentifier"

    override init() {
        super.init()
        if let id = UserDefaults.standard.string(forKey: key) {
            self.userIdentifier = id
            self.isSignedIn = true
        }
    }

    func signIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func signOut() {
        userIdentifier = nil
        isSignedIn = false
        displayName = ""
        UserDefaults.standard.removeObject(forKey: key)
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        let id = credential.user
        userIdentifier = id
        isSignedIn = true
        UserDefaults.standard.set(id, forKey: key)
        if let name = credential.fullName {
            let parts = [name.givenName, name.familyName].compactMap { $0 }
            displayName = parts.joined(separator: " ")
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.error = error.localizedDescription
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}