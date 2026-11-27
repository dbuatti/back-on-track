import SwiftUI

struct SmallWinCard: View {
    @EnvironmentObject var store: AppStore

    private var hasWin: Bool {
        let checks = store.state.days[todayKey()]?.checks ?? [:]
        return checks.contains(where: { $0.value })
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: hasWin ? "checkmark.seal.fill" : "leaf")
                .font(.title3)
                .foregroundStyle(hasWin ? BotTheme.sage : BotTheme.soft)
                .frame(width: 38, height: 38)
                .background((hasWin ? BotTheme.sageSoft : BotTheme.field), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(hasWin ? "Something is done." : "Nothing logged yet.")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
                Text(hasWin ? "That counts. You can stop here if you want." : "That is okay. A quiet day still counts.")
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
            }
            Spacer()
        }
        .padding(16)
        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.line.opacity(0.35), lineWidth: 1))
    }
}
