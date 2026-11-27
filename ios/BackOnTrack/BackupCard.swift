import SwiftUI
import UniformTypeIdentifiers

struct BackupCard: View {
    @EnvironmentObject var store: AppStore
    @State private var exportURL: URL?
    @State private var showingImporter = false
    @State private var message = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BotSectionHeader(title: "Backup & restore", systemImage: "externaldrive")
            Text("Keep a dated JSON copy, or bring one back. Imports only fill gaps — they never erase newer local data.")
                .font(.subheadline).foregroundStyle(BotTheme.soft)
            HStack(spacing: 10) {
                if let exportURL {
                    ShareLink(item: exportURL) {
                        Text("Export")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(BotTheme.accentSoft, in: Capsule())
                            .foregroundStyle(BotTheme.accentDeep)
                    }
                }
                Button("Import JSON") { showingImporter = true }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(BotTheme.sageSoft, in: Capsule())
                    .foregroundStyle(BotTheme.sage)
            }
            if !message.isEmpty {
                Text(message).font(.caption).foregroundStyle(BotTheme.soft)
            }
        }
        .botCard()
        .onAppear { exportURL = store.exportData() }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                Task {
                    let ok = await store.importData(from: url)
                    message = ok ? "Backup restored." : "That file could not be read."
                }
            case .failure:
                message = "Import cancelled."
            }
        }
    }
}