import SwiftUI

struct ProgramCard: View {
    @EnvironmentObject var store: AppStore
    @State private var undoState: Program30State?
    @State private var reflection: String = ""

    var body: some View {
        let p = store.state.settings.program30
        let index = min(max(p.step, 0), Program30.steps.count - 1)
        let step = Program30.steps[index]

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
                Text("A quiet 30 days")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
                Text("Thirty small invitations, at your pace. Nothing to catch up on.")
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

    private func loadedCard(p: Program30State, step: ProgramStep, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Invitation \(index + 1) of \(Program30.steps.count)")
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

            if let nick = step.nick, let url = URL(string: Program30.nickURL) {
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

            if index == Program30.steps.count - 1 {
                Text("That's the thirty. Nothing to score — one line, if you want, about what you noticed. Just for you.")
                    .font(.caption).foregroundStyle(BotTheme.soft)
                TextField("What did you notice? (optional)", text: $reflection, axis: .vertical)
                    .lineLimit(1...3)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: reflection) { _, value in
                        store.state.settings.program30.reflection = value
                        store.save()
                    }
            }

            HStack(spacing: 10) {
                Button {
                    undoState = store.completeProgramStep()
                } label: {
                    Text(index == Program30.steps.count - 1 ? "Keep this step" : "That's enough")
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

            DisclosureGroup("Sequence settings") {
                HStack {
                    Text(p.startedAt.isEmpty ? "No marks yet. Loading out keeps everything." : "Kept where you left it. Loading out keeps every mark.")
                        .font(.caption).foregroundStyle(BotTheme.soft)
                    Spacer()
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
        let p = store.state.settings.program30
        guard !p.lastDoneAt.isEmpty else { return 0 }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: p.lastDoneAt) else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: date), to: Calendar.current.startOfDay(for: Date())).day ?? 0)
    }
}