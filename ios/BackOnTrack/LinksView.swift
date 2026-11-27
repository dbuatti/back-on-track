import SwiftUI
import UIKit

struct LinksView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var auth: AuthManager
    @State private var copied: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Links").font(.largeTitle).bold().foregroundStyle(BotTheme.ink)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("My links").font(.headline).foregroundStyle(BotTheme.ink)
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
                        Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                            .font(.headline).foregroundStyle(BotTheme.ink)
                        if auth.isSignedIn {
                            Text(store.supabase.status)
                                .font(.subheadline).foregroundStyle(BotTheme.soft)
                            HStack {
                                Button { Task { await store.syncNow() } } label: {
                                    Text("Sync now")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(BotTheme.accentSoft, in: Capsule())
                                        .foregroundStyle(BotTheme.accent)
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
            .botBackground()
            .navigationTitle("Links")
            .navigationBarTitleDisplayMode(.inline)
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