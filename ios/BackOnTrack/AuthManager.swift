import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isBusy: Bool = false
    @Published var error: String?
    @Published var displayName: String = ""

    private let supabase = SupabaseManager.shared

    init() {
        isSignedIn = supabase.isSignedIn
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
        if ok { displayName = "Synced account" }
        else { error = supabase.status }
        return ok
    }

    func signInWithPassword(email: String, password: String) async -> Bool {
        isBusy = true
        error = nil
        defer { isBusy = false }
        let ok = await supabase.signInWithPassword(email: email, password: password)
        isSignedIn = ok
        if ok { displayName = "Synced account" }
        else { error = supabase.status }
        return ok
    }

    func signOut() {
        supabase.signOut()
        isSignedIn = false
        displayName = ""
    }
}