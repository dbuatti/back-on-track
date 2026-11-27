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
                Text("Sixty small invitations that adapt to your pace. Nothing to catch up on.")
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

    private func loadedCard(p: Program30State, step: ProgramInvitation, index: Int) -> some View {
        let phase = Program.phases[step.phase]
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Invitation \(index + 1) of \(Program.steps.count)")
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
            VStack(alignment: .leading, spacing: 2) {
                Text(phase.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BotTheme.ink)
                Text(phase.subtitle)
                    .font(.caption2)
                    .foregroundStyle(BotTheme.soft)
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

            if let optional = step.optional {
                Text(optional)
                    .font(.caption)
                    .foregroundStyle(BotTheme.soft)
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
                Text("That's the sixty. Nothing to score — one line, if you want, about what you noticed. Just for you.")
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

            HStack(spacing: 10) {
                Button {
                    undoState = store.completeProgramStep()
                    Haptics.gentle()
                    whisper.show("kept.")
                } label: {
                    Text(index == Program.steps.count - 1 ? "Keep this step" : "That's enough")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(BotTheme.accentGradient, in: Capsule())
                }
                .buttonStyle(.plain)

                if let undoState {
                    Button("Undo") {
                        store.undoProgramStep(undoState)
                        self.undoState = nil
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BotTheme.accent)
                }
            }

            HStack(spacing: 6) {
                ForEach(0..<Program.phases.count, id: \.self) { phaseIndex in
                    Circle()
                        .fill(phaseIndex <= step.phase ? BotTheme.accent : BotTheme.line)
                        .frame(width: 7, height: 7)
                }
                Spacer()
            }

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