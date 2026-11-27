import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isLocalOnly: Bool = false
    @Published var isBusy: Bool = false
    @Published var error: String?
    @Published var displayName: String = ""

    private let supabase = SupabaseManager.shared

    init() {
        isSignedIn = supabase.isSignedIn
        isLocalOnly = UserDefaults.standard.bool(forKey: "bot.localOnly")
    }

    func signInWithPassword(email: String, password: String) async -> Bool {
        isBusy = true
        error = nil
        defer { isBusy = false }
        let ok = await supabase.signInWithPassword(email: email, password: password)
        isSignedIn = ok
        if ok {
            isLocalOnly = false
            UserDefaults.standard.set(false, forKey: "bot.localOnly")
            displayName = "Synced account"
        } else {
            error = supabase.status
        }
        return ok
    }

    func signUp(email: String, password: String) async -> Bool {
        isBusy = true
        error = nil
        defer { isBusy = false }
        let ok = await supabase.signUp(email: email, password: password)
        if ok {
            isSignedIn = true
            isLocalOnly = false
            UserDefaults.standard.set(false, forKey: "bot.localOnly")
            displayName = "Synced account"
        } else {
            error = supabase.status
        }
        return ok
    }

    func signIn(with syncKey: String) async -> Bool {
        let key = syncKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            error = "Paste the sync key from your web app first."
            return false
        }
        isBusy = true
        error = nil
        defer { isBusy = false }
        let ok = await supabase.signIn(with: key)
        isSignedIn = ok
        if ok {
            isLocalOnly = false
            UserDefaults.standard.set(false, forKey: "bot.localOnly")
            displayName = "Synced account"
        } else {
            error = supabase.status
        }
        return ok
    }

    func sendMagicLink(email: String) async -> Bool {
        isBusy = true
        error = nil
        defer { isBusy = false }
        let ok = await supabase.sendMagicLink(email: email)
        if !ok { error = supabase.status }
        return ok
    }

    func handleAuthCallback(_ url: URL) async {
        isBusy = true
        error = nil
        defer { isBusy = false }
        let ok = await supabase.handleAuthCallback(url)
        isSignedIn = ok
        if ok {
            isLocalOnly = false
            UserDefaults.standard.set(false, forKey: "bot.localOnly")
            displayName = "Synced account"
        } else {
            error = supabase.status
        }
    }

    func useLocalOnly() {
        isLocalOnly = true
        UserDefaults.standard.set(true, forKey: "bot.localOnly")
    }

    func signOut() {
        supabase.signOut()
        isSignedIn = false
        isLocalOnly = false
        UserDefaults.standard.set(false, forKey: "bot.localOnly")
        displayName = ""
    }
}