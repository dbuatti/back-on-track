import Foundation
import Combine

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
final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    @Published private(set) var session: SupabaseSession?
    @Published var status: String = "Not synced"
    @Published var lastSync: Date?

    private let baseURL = URL(string: "https://yfgapigmiyclgryqdgne.supabase.co")!
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmZ2FwaWdtaXljbGdyeXFkZ25lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MTU3MDEsImV4cCI6MjA3Nzk5MTcwMX0.YPSk_2bOwLC3kTjJ9j-8YR3degNlMleymbo4X9F_bSo"

    private init() {
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