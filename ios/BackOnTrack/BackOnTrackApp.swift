import SwiftUI
import UIKit

@main
struct BackOnTrackApp: App {
    @StateObject private var auth = AuthManager()
    @StateObject private var store = AppStore()

    init() {
        configureAppearance()
    }

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

    private func configureAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(BotTheme.cream)
        nav.titleTextAttributes = [
            .foregroundColor: UIColor(BotTheme.ink),
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        nav.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(BotTheme.card)
        tab.shadowColor = UIColor(BotTheme.line.opacity(0.45))
        tab.stackedLayoutAppearance.selected.iconColor = UIColor(BotTheme.accent)
        tab.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(BotTheme.accent),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        tab.stackedLayoutAppearance.normal.iconColor = UIColor(BotTheme.soft)
        tab.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(BotTheme.soft),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}