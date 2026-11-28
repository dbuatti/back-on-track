import SwiftUI
import UIKit

struct LinksView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var auth: AuthManager
    @State private var copied: String?
    @State private var showingPersonalization = false

    var body: some View {
        ZStack {
            BotTheme.backgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Image(systemName: "link")
                            .font(.title2)
                            .foregroundStyle(BotTheme.accent)
                            .frame(width: 46, height: 46)
                            .background(BotTheme.accentSoft, in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Links").font(BotTheme.titleFont).foregroundStyle(BotTheme.ink)
                            Text("The useful things, close by.").font(.subheadline).foregroundStyle(BotTheme.soft)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        BotSectionHeader(title: "My links", systemImage: "bookmark")
                        if store.state.settings.myLinks.isEmpty {
                            Text("No personal links yet.")
                                .font(.subheadline).foregroundStyle(BotTheme.soft)
                        } else {
                            ForEach(store.state.settings.myLinks) { link in
                                linkRow(link)
                            }
                        }
                    }
                    .botCard()

                    VStack(alignment: .leading, spacing: 10) {
                        BotSectionHeader(title: "Gmail", systemImage: "envelope")
                        Text("Open Gmail in Safari when you need it. Google sign-in above uses your Google account for sync.")
                            .font(.subheadline).foregroundStyle(BotTheme.soft)
                        Link(destination: URL(string: "https://mail.google.com/")!) {
                            Text("Open Gmail")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(BotTheme.sageSoft, in: Capsule())
                                .foregroundStyle(BotTheme.sage)
                        }
                    }
                    .botCard()

                    BackupCard()

                    VStack(alignment: .leading, spacing: 10) {
                        BotSectionHeader(title: "Make it yours", systemImage: "slider.horizontal.3")
                        Text("Choose what pulls you in and which support cards appear. No diagnosis, no labels — just your preferences.")
                            .font(.subheadline).foregroundStyle(BotTheme.soft)
                        Button("Personalise") { showingPersonalization = true }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(BotTheme.accentGradient, in: Capsule())
                            .buttonStyle(.plain)
                    }
                    .botCard()

                    VStack(alignment: .leading, spacing: 10) {
                        BotSectionHeader(title: "Share Back on Track", systemImage: "square.and.arrow.up")
                        Text("Send the web app to someone on Android or iPhone. They can add it to their Home screen.")
                            .font(.subheadline).foregroundStyle(BotTheme.soft)
                        ShareLink(item: URL(string: "https://dbuatti.github.io/back-on-track/")!) {
                            Text("Share the web app")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(BotTheme.sageSoft, in: Capsule())
                                .foregroundStyle(BotTheme.sage)
                        }
                    }
                    .botCard()

                    VStack(alignment: .leading, spacing: 10) {
                        BotSectionHeader(title: "Sync", systemImage: "arrow.triangle.2.circlepath")
                        if auth.isSignedIn {
                            Text(store.supabase.status)
                                .font(.subheadline).foregroundStyle(BotTheme.soft)
                            HStack {
                                Button { Task { await store.syncNow() } } label: {
                                    Text("Sync now")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(BotTheme.accentGradient, in: Capsule())
                                        .foregroundStyle(.white)
                                        .shadow(color: BotTheme.accent.opacity(0.16), radius: 8, x: 0, y: 4)
                                }
                                Button("Sign out") {
                                    auth.signOut()
                                    store.isReady = false
                                }
                                .font(.subheadline)
                            }
                        } else {
                            Text("Your data is on this phone. Connect an account when you want it on your other devices.")
                                .font(.subheadline).foregroundStyle(BotTheme.soft)
                            Button("Sign in to sync") {
                                auth.isLocalOnly = false
                                UserDefaults.standard.set(false, forKey: "bot.localOnly")
                            }
                            .buttonStyle(.bordered)
                            .tint(BotTheme.accent)
                        }
                    }
                    .botCard()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showingPersonalization) {
                PersonalizationView()
                    .environmentObject(store)
            }
        }
    }

    private func linkRow(_ link: ListItem) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .foregroundStyle(BotTheme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(link.text).font(.subheadline.weight(.semibold)).foregroundStyle(BotTheme.ink)
                Text(link.url ?? "").font(.caption2).foregroundStyle(BotTheme.soft).lineLimit(1)
            }
            Spacer()
            Button { copy(link.url ?? "") } label: {
                Image(systemName: "doc.on.doc").font(.caption)
            }
            .buttonStyle(.plain)
            if let url = URL(string: link.url ?? "") {
                Link(destination: url) { Image(systemName: "arrow.up.right").font(.caption) }
            }
        }
        .padding(.vertical, 8)
    }

    private func copy(_ value: String) {
        UIPasteboard.general.string = value
        copied = value
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = nil }
    }
}