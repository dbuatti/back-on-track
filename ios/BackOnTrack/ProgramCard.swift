import SwiftUI

struct ProgramCard: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @State private var undoState: Program30State?
    @State private var reflection: String = ""

    var body: some View {
        let p = store.state.settings.program30
        let index = min(max(p.step, 0), Program.steps.count - 1)
        let step = Program.effectiveStep(state: store.state, index: index)

        if !p.loaded {
            nudgeCard
        } else if store.programDoneToday() {
            doneCard(p: p)
        } else {
            loadedCard(p: p, step: step, index: index)
        }
    }

    private var nudgeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(BotTheme.accent)
                .frame(width: 38, height: 38)
                .background(BotTheme.accentSoft, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("A quiet 60 days")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
                Text("One small invitation a day, at your pace. Nothing to catch up on.")
                    .font(.caption).foregroundStyle(BotTheme.soft)
            }
            Spacer()
            Button("Load in") { store.setProgramLoaded(true) }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(BotTheme.accentGradient, in: Capsule())
                .buttonStyle(.plain)
        }
        .padding(16)
        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.accent.opacity(0.12), lineWidth: 1))
        .shadow(color: BotTheme.accent.opacity(0.06), radius: 14, x: 0, y: 7)
    }

    /// A soft green resting card. It replaces the invitation for the rest of
    /// the day — no further clicking, no way to rush ahead.
    private func doneCard(p: Program30State) -> some View {
        let dayNumber = p.done.values.filter { !$0.isEmpty }.count
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(BotTheme.sage)
                    .frame(width: 40, height: 40)
                    .background(BotTheme.sageSoft, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's invitation is complete.")
                        .font(BotTheme.headingFont)
                        .foregroundStyle(BotTheme.ink)
                    Text("You've kept \(dayNumber) \(dayNumber == 1 ? "day" : "days") — small steps, slowly. Come back tomorrow for the next one. Nothing to catch up on.")
                        .font(.subheadline)
                        .foregroundStyle(BotTheme.soft)
                }
                Spacer()
            }
            if let undoState {
                Button("Undo today's mark") {
                    store.undoProgramStep(undoState)
                    self.undoState = nil
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(BotTheme.sage)
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(
            LinearGradient(colors: [BotTheme.sageSoft, BotTheme.card], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(BotTheme.sage.opacity(0.22), lineWidth: 1))
        .shadow(color: BotTheme.sage.opacity(0.10), radius: 16, x: 0, y: 8)
        .onAppear { undoState = nil }
    }

    private func loadedCard(p: Program30State, step: ProgramInvitation, index: Int) -> some View {
        let phase = Program.phases[step.phase]
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("One invitation for today")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BotTheme.accent)
                Spacer()
                Text(step.kindLabel)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(BotTheme.accentSoft, in: Capsule())
                    .foregroundStyle(BotTheme.accentDeep)
            }
            HStack(spacing: 6) {
                Image(systemName: "leaf")
                    .font(.caption2)
                    .foregroundStyle(BotTheme.accent)
                Text(phase.title)
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
                Text(phase.subtitle)
                    .font(.caption2)
                    .foregroundStyle(BotTheme.soft)
                    .lineLimit(1)
            }

            if gapDays >= 2 {
                Text("Your step is right where you left it. Nothing to catch up on.")
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BotTheme.accentSoft.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
            }

            Text(step.title)
                .font(.system(.title2, design: .rounded).weight(.semibold))
                .foregroundStyle(BotTheme.ink)
            Text(step.invitation)
                .font(.body)
                .foregroundStyle(BotTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            if let optional = step.optional {
                Text(optional)
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let nick = step.nick, let url = URL(string: Program.nickURL) {
                Link(destination: url) {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones")
                        Text("Open Nick Moss · \(nick)")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BotTheme.accentDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(BotTheme.accentSoft, in: Capsule())
                }
            }

            DisclosureGroup("Even smaller") {
                Text(step.smaller)
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption)
            .foregroundStyle(BotTheme.soft)

            if index == Program.steps.count - 1 {
                Text("Nothing to score — one line, if you want, about what you noticed. Just for you.")
                    .font(.caption).foregroundStyle(BotTheme.soft)
                TextField("What did you notice? (optional)", text: $reflection, axis: .vertical)
                    .lineLimit(1...3)
                    .textFieldStyle(.roundedBorder)
                    .keyboardDoneButton()
                    .onChange(of: reflection) { _, value in
                        store.state.settings.program30.reflection = value
                        store.save()
                    }
            }

            Button {
                undoState = store.completeProgramStep()
                Haptics.gentle()
                whisper.show("kept.")
            } label: {
                Text("That's enough for today")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(BotTheme.accentGradient, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(store.programDoneToday())

            DisclosureGroup("Sequence settings") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pace")
                        .font(.caption.weight(.semibold)).foregroundStyle(BotTheme.ink)
                    Picker("Pace", selection: Binding(
                        get: { p.pace ?? "gentle" },
                        set: { store.setProgramPace($0) }
                    )) {
                        Text("Gentle").tag("gentle")
                        Text("Steady").tag("steady")
                        Text("Minimal").tag("minimal")
                    }
                    .pickerStyle(.segmented)
                    Text(p.startedAt.isEmpty ? "No marks yet. Loading out keeps everything." : "Kept where you left it. Loading out keeps every mark.")
                        .font(.caption).foregroundStyle(BotTheme.soft)
                    Button("Load out") { store.setProgramLoaded(false) }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BotTheme.accent)
                }
            }
            .font(.caption)
            .foregroundStyle(BotTheme.soft)
        }
        .padding(18)
        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(BotTheme.accent.opacity(0.12), lineWidth: 1))
        .shadow(color: BotTheme.accent.opacity(0.06), radius: 16, x: 0, y: 8)
        .onAppear { reflection = p.reflection }
    }

    private var gapDays: Int {
        Program.daysSince(store.state.settings.program30.lastDoneAt)
    }
}
