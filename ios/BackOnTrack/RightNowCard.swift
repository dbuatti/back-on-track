import SwiftUI

struct RightNowCard: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    var disabled: Bool = false
    var onIntention: () -> Void = {}
    var onAnchor: () -> Void = {}
    @State private var showingPause = false

    private struct Suggestion {
        let title: String
        let detail: String
        let icon: String
        let tint: Color
        let action: Action
        enum Action { case wake, bed, pause, intention, anchor }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let suggestion = suggestion(at: context.date)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(BotTheme.accent)
                    Text("Right now")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BotTheme.accent)
                    Spacer()
                    Text(timeLabel(context.date))
                        .font(.caption2)
                        .foregroundStyle(BotTheme.soft)
                }
                HStack(spacing: 12) {
                    Image(systemName: suggestion.icon)
                        .font(.title2)
                        .foregroundStyle(suggestion.tint)
                        .frame(width: 42, height: 42)
                        .background(suggestion.tint.opacity(0.12), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(suggestion.title)
                            .font(BotTheme.headingFont)
                            .foregroundStyle(BotTheme.ink)
                        Text(suggestion.detail)
                            .font(.caption)
                            .foregroundStyle(BotTheme.soft)
                    }
                    Spacer()
                }
                Button(disabled ? "Done for today" : actionLabel(suggestion.action)) {
                    perform(suggestion.action)
                }
                .disabled(disabled)
                .opacity(disabled ? 0.5 : 1)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(suggestion.tint, in: Capsule())
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(suggestion.tint.opacity(0.16), lineWidth: 1))
            .shadow(color: suggestion.tint.opacity(0.07), radius: 14, x: 0, y: 7)
            .sheet(isPresented: $showingPause) {
                CodingPauseSheet().environmentObject(store)
            }
        }
    }

    private func suggestion(at date: Date) -> Suggestion {
        let today = todayKey()
        let record = store.state.days[today]
        let hour = Calendar.current.component(.hour, from: date)
        let mood = record?.mood
        let focus = store.state.settings.personalization?.focusLabel ?? "a gentle pause"
        let gap = Program.daysSince(store.state.settings.program30.lastDoneAt)

        if mood == "low" {
            return Suggestion(title: "Make it smaller", detail: "One breath, one look around — whatever is least.", icon: "minus.circle", tint: BotTheme.sage, action: .anchor)
        }
        if hour >= 5 && hour < 12 && record?.wakeTime == nil {
            return Suggestion(title: "Log your wake time", detail: "Even after a rough night, the real time is useful.", icon: "sunrise", tint: BotTheme.sun, action: .wake)
        }
        if hour >= 20 && record?.bedTime == nil {
            return Suggestion(title: "Log bedtime", detail: "Whenever you get there is the right time.", icon: "bed.double", tint: BotTheme.evening, action: .bed)
        }
        if gap >= 3 && store.state.settings.program30.loaded {
            return Suggestion(title: "Your invitation is waiting", detail: "Nothing to catch up on. Come back gently.", icon: "sparkles", tint: BotTheme.accent, action: .anchor)
        }
        if focus != "a gentle pause" {
            return Suggestion(title: "A pause before \(focus.lowercased())", detail: "One minute to stop gently, if you want to.", icon: "pause.circle", tint: BotTheme.evening, action: .pause)
        }
        if record?.intention.isEmpty ?? true {
            return Suggestion(title: "Choose one intention", detail: "A word, a feeling, a direction. Nothing more.", icon: "sparkles", tint: BotTheme.accent, action: .intention)
        }
        return Suggestion(title: "Pick one small anchor", detail: "One thing, given a minute or two.", icon: "leaf", tint: BotTheme.sage, action: .anchor)
    }

    private func actionLabel(_ action: Suggestion.Action) -> String {
        switch action {
        case .wake: return "Log now"
        case .bed: return "Log now"
        case .pause: return "Open pause"
        case .intention: return "Add intention"
        case .anchor: return "Show me"
        }
    }

    private func perform(_ action: Suggestion.Action) {
        if disabled { return }
        switch action {
        case .wake:
            store.logTime("wake")
            Haptics.gentle()
            whisper.show("noted.")
        case .bed:
            store.logTime("bed")
            Haptics.gentle()
            whisper.show("noted.")
        case .pause:
            Haptics.gentle()
            showingPause = true
        case .intention: onIntention()
        case .anchor: onAnchor()
        }
    }

    private func timeLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE, HH:mm"
        return f.string(from: date)
    }
}
