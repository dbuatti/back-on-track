import SwiftUI

struct DoneForTodayCard: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager

    private var isDone: Bool { store.state.settings.doneForToday == todayKey() }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isDone ? "moon.stars.fill" : "checkmark.circle")
                .font(.title3)
                .foregroundStyle(isDone ? BotTheme.evening : BotTheme.sage)
                .frame(width: 38, height: 38)
                .background((isDone ? BotTheme.eveningSoft : BotTheme.sageSoft), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(isDone ? "Done for today" : "Ready to stop?")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
                Text(isDone ? "Nothing to change right now. Come back tomorrow." : "Hide the editing controls and stop tinkering.")
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
            }
            Spacer()
            Button(isDone ? "Reopen" : "That's enough") {
                withAnimation(.easeOut(duration: 0.25)) {
                    store.setDoneForToday(!isDone)
                }
                Haptics.gentle()
                whisper.show(isDone ? "back." : "enough.")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(isDone ? BotTheme.evening : BotTheme.sage)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background((isDone ? BotTheme.eveningSoft : BotTheme.sageSoft), in: Capsule())
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.line.opacity(0.35), lineWidth: 1))
    }
}
