import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published var state: AppState = AppState()
    @Published var isReady: Bool = false

    let supabase = SupabaseManager.shared

    func bootstrap(auth: AuthManager) async {
        loadLocal()
        if auth.isSignedIn {
            if let remote = await supabase.fetchState() {
                let localStamp = state.settings.updatedAt
                let remoteStamp = remote.settings.updatedAt
                if remoteStamp > localStamp {
                    state = remote
                    persistLocal()
                } else if localStamp > remoteStamp {
                    await supabase.pushState(state)
                }
            } else {
                await supabase.pushState(state)
            }
        }
        isReady = true
    }

    func save() {
        state.settings.updatedAt = Date().timeIntervalSince1970 * 1000
        persistLocal()
        Task { await supabase.pushState(state) }
    }

    func syncNow() async {
        guard supabase.isSignedIn else { return }
        if let remote = await supabase.fetchState() {
            let localStamp = state.settings.updatedAt
            let remoteStamp = remote.settings.updatedAt
            if remoteStamp > localStamp {
                state = remote
                persistLocal()
            } else if localStamp > remoteStamp {
                await supabase.pushState(state)
            }
        } else {
            await supabase.pushState(state)
        }
    }

    private func persistLocal() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "bot.state")
        }
    }

    private func loadLocal() {
        if let data = UserDefaults.standard.data(forKey: "bot.state"),
           let decoded = try? JSONDecoder().decode(AppState.self, from: data) {
            state = decoded
        }
    }
}