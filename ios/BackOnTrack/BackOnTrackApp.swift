import SwiftUI
import CloudKit

@main
struct BackOnTrackApp: App {
    @StateObject private var auth = AuthManager()
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(store)
                .task {
                    await store.bootstrap(auth: auth)
                }
        }
    }
}