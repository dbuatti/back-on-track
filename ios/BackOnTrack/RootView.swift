import SwiftUI

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
        .preferredColorScheme(.light)
        .task { await store.bootstrap(auth: auth) }
        .onChange(of: auth.isSignedIn) { _, signedIn in
            if signedIn {
                store.isReady = false
                Task { await store.bootstrap(auth: auth) }
            }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var syncKey: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Back on Track").font(.largeTitle).bold()
            Text("Connect this iPhone to your web app's sync.").foregroundStyle(.secondary)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Text("Email").font(.headline)
                TextField("you@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }
            Button(auth.isBusy ? "Signing in…" : "Sign in") {
                Task { _ = await auth.signInWithPassword(email: email, password: password) }
            }
            .buttonStyle(.borderedProminent)
            .disabled(auth.isBusy || email.isEmpty || password.isEmpty)
            DisclosureGroup("Use a sync key instead") {
                TextField("Paste from web → Links → Sync key", text: $syncKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                Button("Connect with key") {
                    Task { _ = await auth.signIn(with: syncKey) }
                }
                .disabled(auth.isBusy || syncKey.isEmpty)
            }
            .font(.footnote)
            if let err = auth.error {
                Text(err).foregroundStyle(.red).font(.caption)
            }
            Spacer()
        }
        .padding()
    }
}