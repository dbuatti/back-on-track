import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var store: AppStore
    @State private var tab: Tab = .home

    enum Tab { case home, windDown, focus, links, shelves }

    var body: some View {
        Group {
            if !auth.isSignedIn && !auth.isLocalOnly {
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
    @State private var email = ""
    @State private var password = ""
    @State private var syncKey = ""
    @State private var mode: Mode = .signIn

    enum Mode { case signIn, createAccount }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Back on Track").font(.largeTitle.bold()).foregroundStyle(BotTheme.ink)
                    Text("A calm daily rhythm. Start on this phone, or connect for sync.")
                        .font(.subheadline).foregroundStyle(BotTheme.soft)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                Picker("Account mode", selection: $mode) {
                    Text("Sign in").tag(Mode.signIn)
                    Text("Create account").tag(Mode.createAccount)
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email").font(.headline).foregroundStyle(BotTheme.ink)
                    TextField("you@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password)
                        .textContentType(mode == .createAccount ? .newPassword : .password)
                        .textFieldStyle(.roundedBorder)
                    if mode == .createAccount {
                        Text("At least 8 characters. You may get a confirmation email.")
                            .font(.caption).foregroundStyle(BotTheme.soft)
                    }
                }
                .botCard()

                Button {
                    Task {
                        if mode == .signIn {
                            _ = await auth.signInWithPassword(email: email, password: password)
                        } else {
                            _ = await auth.signUp(email: email, password: password)
                        }
                    }
                } label: {
                    Text(auth.isBusy ? "Please wait…" : (mode == .signIn ? "Sign in" : "Create account"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(BotTheme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(auth.isBusy || email.isEmpty || password.count < 8)

                DisclosureGroup("Connect from the web app") {
                    TextField("Paste your sync key", text: $syncKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    Button("Connect with key") {
                        Task { _ = await auth.signIn(with: syncKey) }
                    }
                    .disabled(auth.isBusy || syncKey.isEmpty)
                }
                .font(.footnote)
                .foregroundStyle(BotTheme.soft)

                Divider()

                Button("Use on this phone only") {
                    auth.useLocalOnly()
                }
                .buttonStyle(.bordered)
                .tint(BotTheme.accent)

                Text("You can connect to sync later from Links.")
                    .font(.caption).foregroundStyle(BotTheme.soft)

                if let err = auth.error {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(BotTheme.accent)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .botBackground()
    }
}