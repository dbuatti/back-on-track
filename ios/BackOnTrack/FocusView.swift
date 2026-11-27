import SwiftUI

private struct FocusSection: Identifiable {
    let id: String
    let title: String
    let icon: String
    let line: String
    let tasks: [ListItem]

    var isProgram: Bool { id == "program" }
}

struct FocusView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @State private var index = 0
    @State private var finished = false

    private var isSunday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 1
    }

    private var sections: [FocusSection] {
        var result: [FocusSection] = [
            FocusSection(id: "morning", title: "Morning", icon: "sun.max", line: "Begin gently. Nothing needs to be perfect.", tasks: store.state.settings.lists.morning),
            FocusSection(id: "anchors", title: "Daily anchors", icon: "leaf", line: "One thing that keeps the day steady.", tasks: store.state.settings.lists.anchors),
            FocusSection(id: "instead", title: "Instead of gaming", icon: "gamecontroller", line: "A softer way to land in the evening.", tasks: store.state.settings.lists.instead)
        ]
        let selfReg = store.state.settings.shelves.first(where: { $0.id == "sh_selfreg" })?.items ?? []
        if !selfReg.isEmpty {
            result.append(FocusSection(
                id: "selfreg",
                title: "Self-regulation",
                icon: "music.note",
                line: "Piano improvisation, a good shake, or one quiet note.",
                tasks: selfReg.map { ListItem(id: $0.id, text: $0.text, note: $0.note, small: $0.small, url: nil) }
            ))
        }
        if store.state.settings.program30.loaded {
            result.append(FocusSection(id: "program", title: "Quiet program", icon: "sparkles", line: "One invitation, at your pace.", tasks: []))
        }
        return result
    }

    var body: some View {
        NavigationStack {
            Group {
                if isSunday {
                    sundayView
                } else if sections.isEmpty {
                    emptyView
                } else {
                    focusView
                }
            }
            .botBackground()
            .navigationBarHidden(true)
        }
    }

    private var sundayView: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(BotTheme.evening)
                .frame(width: 100, height: 100)
                .background(BotTheme.eveningSoft, in: Circle())
            Text("Rest is the practice.")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
                .multilineTextAlignment(.center)
            Text("No doing list today. Log sleep if you like, then let the day be quiet.")
                .font(.subheadline)
                .foregroundStyle(BotTheme.soft)
                .multilineTextAlignment(.center)
            VStack(spacing: 10) {
                Button("Log bedtime") { store.logTime("bed") }
                    .modifier(SoftButtonStyle(tint: BotTheme.evening))
                Button("Log wake time") { store.logTime("wake") }
                    .modifier(SoftButtonStyle(tint: BotTheme.sun))
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .padding(.top, 40)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(BotTheme.accent)
            Text("Nothing to focus on yet.")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
            Text("Add a small task from Home, or borrow one from Shelves.")
                .font(.subheadline).foregroundStyle(BotTheme.soft)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var focusView: some View {
        let safeIndex = min(index, sections.count - 1)
        let section = sections[safeIndex]
        return VStack(spacing: 18) {
            Text("Focus")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            if finished {
                finishedView
            } else {
                VStack(spacing: 16) {
                    Image(systemName: section.icon)
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(BotTheme.accent)
                        .frame(width: 84, height: 84)
                        .background(
                            RadialGradient(colors: [BotTheme.accentSoft, BotTheme.card], center: .center, startRadius: 4, endRadius: 64),
                            in: Circle()
                        )
                        .overlay(Circle().stroke(BotTheme.accent.opacity(0.12), lineWidth: 1))

                    VStack(spacing: 6) {
                        Text(section.title)
                            .font(.system(.title2, design: .rounded).weight(.semibold))
                            .foregroundStyle(BotTheme.ink)
                        Text(section.line)
                            .font(.subheadline)
                            .foregroundStyle(BotTheme.soft)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 6) {
                        ForEach(0..<sections.count, id: \.self) { i in
                            Circle()
                                .fill(i == safeIndex ? BotTheme.accent : BotTheme.line)
                                .frame(width: 7, height: 7)
                        }
                    }
                    .padding(.top, 2)

                    if section.isProgram {
                        ProgramCard()
                            .environmentObject(store)
                    } else if section.tasks.isEmpty {
                        Text("Nothing here yet. One quiet thing is enough.")
                            .font(.subheadline)
                            .foregroundStyle(BotTheme.soft)
                            .botCard()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(section.tasks) { task in
                                taskRow(task)
                                if task.id != section.tasks.last?.id {
                                    Divider().padding(.leading, 48)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.line.opacity(0.35), lineWidth: 1))
                        .shadow(color: BotTheme.ink.opacity(0.04), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)

                HStack(spacing: 12) {
                    Button { if index > 0 { index -= 1 } } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .frame(width: 52, height: 52)
                            .background(BotTheme.card, in: Circle())
                            .foregroundStyle(BotTheme.ink)
                    }
                    .buttonStyle(.plain)
                    .disabled(index == 0)
                    .opacity(index == 0 ? 0.4 : 1)

                    Button {
                        if index < sections.count - 1 { index += 1 }
                        else { finished = true }
                    } label: {
                        Text(safeIndex == sections.count - 1 ? "Done" : "Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(BotTheme.accentGradient, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    if safeIndex < sections.count - 1 {
                        Color.clear.frame(width: 52, height: 52)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(BotTheme.sage)
            Text("That's enough.")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
            Text("You don't need to finish everything. Come back whenever you want.")
                .font(.subheadline)
                .foregroundStyle(BotTheme.soft)
                .multilineTextAlignment(.center)
            Button("Start again") {
                finished = false
                index = 0
            }
            .modifier(SoftButtonStyle(tint: BotTheme.accent))
        }
        .padding()
    }

    private func taskRow(_ task: ListItem) -> some View {
        let checked = store.state.days[todayKey()]?.checks[task.id] ?? false
        return HStack(alignment: .center, spacing: 12) {
            Button { toggle(task.id) } label: {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checked ? BotTheme.accent : BotTheme.soft)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.text)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.text)
                    .font(.subheadline)
                    .foregroundStyle(BotTheme.ink)
                    .strikethrough(checked, color: BotTheme.soft)
                DisclosureGroup("Even smaller") {
                    Text(task.small ?? "Just the smallest part.")
                        .font(.caption)
                        .foregroundStyle(BotTheme.soft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.caption)
                .foregroundStyle(BotTheme.soft)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func toggle(_ id: String) {
        let today = todayKey()
        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
        let current = store.state.days[today]?.checks[id] ?? false
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            store.state.days[today]?.checks[id] = !current
        }
        store.save()
        Haptics.tap()
        if !current { whisper.show() }
    }
}

private struct SoftButtonStyle: ViewModifier {
    let tint: Color
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(tint.opacity(0.14), in: Capsule())
    }
}
