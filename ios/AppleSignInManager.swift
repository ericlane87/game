import AuthenticationServices

final class AppleSignInManager: NSObject {
  static let shared = AppleSignInManager()
  private override init() {}

  private var completion: ((Result<ASAuthorizationAppleIDCredential, Error>) -> Void)?

  func signIn(presentationAnchor: ASPresentationAnchor, completion: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
    self.completion = completion
    let provider = ASAuthorizationAppleIDProvider()
    let request = provider.createRequest()
    request.requestedScopes = [.fullName, .email]
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
      completion?(.success(credential))
    } else {
      completion?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected credential type."])))
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    completion?(.failure(error))
  }
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let window = UIApplication.shared.connectedScenes
      .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
      .first else {
      return ASPresentationAnchor()
    }
    return window
  }
}
