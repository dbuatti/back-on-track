import Foundation
import Combine
import CryptoKit
import Security
import AuthenticationServices
import UIKit

struct SupabaseSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Double
    let userID: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case userID = "user_id"
    }
}

@MainActor
final class SupabaseManager: NSObject, ObservableObject {
    static let shared = SupabaseManager()

    @Published private(set) var session: SupabaseSession?
    @Published var status: String = "Not synced"
    @Published var lastSync: Date?
    private var authSession: ASWebAuthenticationSession?

    private let baseURL = URL(string: "https://yfgapigmiyclgryqdgne.supabase.co")!
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmZ2FwaWdtaXljbGdyeXFkZ25lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MTU3MDEsImV4cCI6MjA3Nzk5MTcwMX0.YPSk_2bOwLC3kTjJ9j-8YR3degNlMleymbo4X9F_bSo"

    private override init() {
        super.init()
        if let data = UserDefaults.standard.data(forKey: "bot.supabaseSession"),
           let decoded = try? JSONDecoder().decode(SupabaseSession.self, from: data) {
            self.session = decoded
        }
    }

    var isSignedIn: Bool { session != nil }

    func signIn(with refreshToken: String) async -> Bool {
        do {
            let token = try await refreshSession(refreshToken)
            session = token
            persist()
            status = "Signed in"
            return true
        } catch {
            status = "Sign-in failed: \(error.localizedDescription)"
            return false
        }
    }

    func signInWithPassword(email: String, password: String) async -> Bool {
        do {
            var request = URLRequest(url: baseURL.appendingPathComponent("auth/v1/token"))
            request.httpMethod = "POST"
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            comps.queryItems = [URLQueryItem(name: "grant_type", value: "password")]
            request.url = comps.url
            request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                status = "Sign-in failed. Check your email and password."
                return false
            }
            let token = try parseSession(data)
            session = token
            persist()
            status = "Signed in"
            return true
        } catch {
            status = "Sign-in failed: \(error.localizedDescription)"
            return false
        }
    }

    func signUp(email: String, password: String) async -> Bool {
        do {
            var request = URLRequest(url: baseURL.appendingPathComponent("auth/v1/signup"))
            request.httpMethod = "POST"
            request.setValue(anonKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                status = "Couldn't create the account. Check the email and password."
                return false
            }
            let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if obj?["access_token"] != nil {
                let token = try parseSession(data)
                session = token
                persist()
                status = "Account created"
                return true
            }
            status = "Account created. Check your email to confirm it, then sign in."
            return false
        } catch {
            status = "Couldn't create the account: \(error.localizedDescription)"
            return false
        }
    }

    func sendMagicLink(email: String) async -> Bool {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard address.contains("@") else {
            status = "Enter a valid email address."
            return false
        }
        let verifier = makePKCEVerifier()
        let challenge = makePKCEChallenge(verifier)
        UserDefaults.standard.set(verifier, forKey: "bot.pkceVerifier")

        var request = URLRequest(url: baseURL.appendingPathComponent("auth/v1/otp"))
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "redirect_to", value: "backontrack://auth-callback")]
        request.url = comps.url
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": address,
            "create_user": true,
            "code_challenge": challenge,
            "code_challenge_method": "S256"
        ])
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                status = "Couldn't send the link. Try again in a minute."
                return false
            }
            status = "Link sent. Open it on this iPhone to finish signing in."
            return true
        } catch {
            status = "Couldn't send the link: \(error.localizedDescription)"
            return false
        }
    }

    func handleAuthCallback(_ url: URL) async -> Bool {
        var code: String?
        var access: String?
        var refresh: String?
        var expires: Double?
        var expiresIn: Double?

        if let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            code = query.first(where: { $0.name == "code" })?.value
            access = query.first(where: { $0.name == "access_token" })?.value
            refresh = query.first(where: { $0.name == "refresh_token" })?.value
            if let value = query.first(where: { $0.name == "expires_at" })?.value {
                expires = Double(value)
            }
            if let value = query.first(where: { $0.name == "expires_in" })?.value {
                expiresIn = Double(value)
            }
        }
        if let fragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment {
            let items = fragment.split(separator: "&").compactMap { part -> URLQueryItem? in
                let bits = part.split(separator: "=", maxSplits: 1).map(String.init)
                guard bits.count == 2 else { return nil }
                return URLQueryItem(name: bits[0], value: bits[1].removingPercentEncoding ?? bits[1])
            }
            code = code ?? items.first(where: { $0.name == "code" })?.value
            access = access ?? items.first(where: { $0.name == "access_token" })?.value
            refresh = refresh ?? items.first(where: { $0.name == "refresh_token" })?.value
            if expires == nil, let value = items.first(where: { $0.name == "expires_at" })?.value {
                expires = Double(value)
            }
            if expiresIn == nil, let value = items.first(where: { $0.name == "expires_in" })?.value {
                expiresIn = Double(value)
            }
        }

        do {
            if let code {
                guard let verifier = UserDefaults.standard.string(forKey: "bot.pkceVerifier") else {
                    status = "That sign-in link has expired. Request a new one."
                    return false
                }
                var request = URLRequest(url: baseURL.appendingPathComponent("auth/v1/token"))
                request.httpMethod = "POST"
                request.setValue(anonKey, forHTTPHeaderField: "apikey")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
                comps.queryItems = [URLQueryItem(name: "grant_type", value: "pkce")]
                request.url = comps.url
                request.httpBody = try JSONSerialization.data(withJSONObject: ["auth_code": code, "code_verifier": verifier])
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    status = "That sign-in link has expired. Request a new one."
                    return false
                }
                let token = try parseSession(data)
                session = token
                persist()
                UserDefaults.standard.removeObject(forKey: "bot.pkceVerifier")
                status = "Signed in"
                return true
            }
            if let access, let refresh {
                let expiry = expires ?? (Date().timeIntervalSince1970 + (expiresIn ?? 3600))
                let payload: [String: Any] = [
                    "access_token": access,
                    "refresh_token": refresh,
                    "expires_at": expiry,
                    "user": ["id": decodeUserID(from: access)]
                ]
                let data = try JSONSerialization.data(withJSONObject: payload)
                session = try parseSession(data)
                persist()
                status = "Signed in"
                return true
            }
        } catch {
            status = "Sign-in failed: \(error.localizedDescription)"
        }
        return false
    }

    private func makePKCEVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func makePKCEChallenge(_ verifier: String) -> String {
        Data(SHA256.hash(data: Data(verifier.utf8))).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func decodeUserID(from token: String) -> String {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return "" }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let data = Data(base64Encoded: base64),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return "" }
        return obj["sub"] as? String ?? ""
    }

    func signInWithGoogle() async -> Bool {
        // GoTrue appends `code` + `state` to redirect_to itself. Make sure the
        // allow-listed redirect on the Supabase project is the plain web URL —
        // the ASWebAuthenticationSession intercepts it before Safari opens it.
        guard let authURL = URL(string: "\(baseURL.absoluteString)/auth/v1/authorize?provider=google&redirect_to=backontrack%3A%2F%2Fauth-callback") else {
            status = "Couldn't start Google sign-in."
            return false
        }
        do {
            let callback = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                let session = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: "backontrack"
                ) { url, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: NSError(domain: "Google", code: 1, userInfo: [NSLocalizedDescriptionKey: "No callback from Google."]))
                    }
                }
                session.presentationContextProvider = self
                session.prefersEphemeralWebBrowserSession = false
                self.authSession = session
                session.start()
            }
            return await handleAuthCallback(callback)
        } catch {
            status = "Google sign-in was cancelled or failed."
            return false
        }
    }

    func signOut() {
        session = nil
        UserDefaults.standard.removeObject(forKey: "bot.supabaseSession")
        status = "Signed out"
    }

    @discardableResult
    func validSession() async -> SupabaseSession? {
        guard var current = session else { return nil }
        if current.expiresAt < Date().timeIntervalSince1970 + 30 {
            do {
                current = try await refreshSession(current.refreshToken)
                session = current
                persist()
            } catch {
                signOut()
                return nil
            }
        }
        return current
    }

    func fetchState() async -> AppState? {
        guard let s = await validSession() else { return nil }
        var request = URLRequest(url: baseURL.appendingPathComponent("rest/v1/back_on_track_state"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(s.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        // query
        var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "user_id", value: "eq.\(s.userID)"),
            URLQueryItem(name: "select", value: "state")
        ]
        request.url = comps.url
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return nil }
            if !(200..<300).contains(http.statusCode) {
                status = "Pull failed (\(http.statusCode))"
                return nil
            }
            let rows = try JSONDecoder().decode([[String: AppState]].self, from: data)
            if let remote = rows.first?["state"] {
                status = "Pulled"
                lastSync = Date()
                return remote
            }
            status = "No remote state"
        } catch {
            status = "Pull failed: \(error.localizedDescription)"
        }
        return nil
    }

    func pushState(_ state: AppState) async {
        guard let s = await validSession() else { return }
        struct Payload: Codable {
            let userId: String
            let state: AppState
            let updatedAt: String
            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case state
                case updatedAt = "updated_at"
            }
        }
        let payload = Payload(
            userId: s.userID,
            state: state,
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        let body = try? JSONEncoder().encode(payload)
        var request = URLRequest(url: baseURL.appendingPathComponent("rest/v1/back_on_track_state"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(s.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = body
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                status = "Pushed"
                lastSync = Date()
            } else {
                status = "Push failed"
            }
        } catch {
            status = "Push failed: \(error.localizedDescription)"
        }
    }

    private func refreshSession(_ refreshToken: String) async throws -> SupabaseSession {
        var request = URLRequest(url: baseURL.appendingPathComponent("auth/v1/token"))
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var comps = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token")]
        request.url = comps.url
        request.httpBody = try JSONSerialization.data(withJSONObject: ["refresh_token": refreshToken])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "Supabase", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid or expired sync key"])
        }
        return try parseSession(data)
    }

    private func parseSession(_ data: Data) throws -> SupabaseSession {
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let access = obj?["access_token"] as? String,
              let refresh = obj?["refresh_token"] as? String,
              let expires = obj?["expires_at"] as? Double,
              let user = obj?["user"] as? [String: Any],
              let id = user["id"] as? String else {
            throw NSError(domain: "Supabase", code: 2, userInfo: [NSLocalizedDescriptionKey: "Bad session response"])
        }
        return SupabaseSession(accessToken: access, refreshToken: refresh, expiresAt: expires, userID: id)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: "bot.supabaseSession")
        }
    }
}

extension SupabaseManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}