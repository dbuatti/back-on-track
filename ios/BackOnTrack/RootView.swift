import SwiftUI
import AuthenticationServices

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var store: AppStore
    @State private var tab: Tab = .home

    enum Tab { case home, windDown, focus, links, shelves }

    var body: some View {
        Group {
            if !auth.isSignedIn {
                SignInView()
            } else if !store.isReady {
                ProgressView("Loading…")
            } else {
                TabView(selection: $tab) {
                    HomeView().tabItem { Label("Home", systemImage: "house") }.tag(Tab.home)
                    WindDownView().tabItem { Label("Wind down", systemImage: "moon") }.tag(Tab.windDown)
                    FocusView().tabItem { Label("Focus", systemImage: "target") }.tag(Tab.focus)
                    LinksView().tabItem { Label("Links", systemImage: "link") }.tag(Tab.links)
                    ShelvesView().tabItem { Label("Shelves", systemImage: "tray") }.tag(Tab.shelves)
                }
            }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    var body: some View {
        VStack(spacing: 24) {
            Text("Back on Track").font(.largeTitle).bold()
            Text("A calm daily rhythm.").foregroundStyle(.secondary)
            Spacer()
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authz):
                    if let cred = authz.credential as? ASAuthorizationAppleIDCredential {
                        auth.userIdentifier = cred.user
                        auth.isSignedIn = true
                        UserDefaults.standard.set(cred.user, forKey: "bot.appleUserIdentifier")
                        if let name = cred.fullName {
                            auth.displayName = [name.givenName, name.familyName].compactMap { $0 }.joined(separator: " ")
                        }
                    }
                case .failure(let error):
                    auth.error = error.localizedDescription
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal)
            if let err = auth.error { Text(err).foregroundStyle(.red).font(.caption) }
            Spacer()
        }
        .padding()
    }
}