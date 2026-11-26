import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published var state: AppState = AppState()
    @Published var isReady: Bool = false

    let cloud = CloudKitManager()

    func bootstrap(auth: AuthManager) async {
        // Try CloudKit first
        if let remote = await cloud.fetchState() {
            // merge: remote wins if newer
            let localStamp = state.settings.updatedAt
            let remoteStamp = remote.settings.updatedAt
            if remoteStamp > localStamp {
                state = remote
            } else if localStamp > remoteStamp {
                await cloud.pushState(state)
            }
        } else {
            // no remote; push local if signed in
            if auth.isSignedIn { await cloud.pushState(state) }
        }
        isReady = true
    }

    func save() {
        state.settings.updatedAt = Date().timeIntervalSince1970 * 1000
        // persist locally
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "bot.state")
        }
        // push to cloud
        Task { await cloud.pushState(state) }
    }

    func loadLocal() {
        if let data = UserDefaults.standard.data(forKey: "bot.state"),
           let decoded = try? JSONDecoder().decode(AppState.self, from: data) {
            state = decoded
        }
    }
}