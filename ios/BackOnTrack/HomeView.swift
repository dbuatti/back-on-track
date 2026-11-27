import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @State private var intention: String = ""
    @State private var editing = false
    @State private var addingTo: String?
    @State private var newTask = ""
    @State private var newSmall = ""
    @State private var removing: ListItem?
    @State private var removeFrom = ""

    private var doneForToday: Bool { store.state.settings.doneForToday == todayKey() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Image(systemName: "sun.max.fill")
                            .font(.title2)
                            .foregroundStyle(BotTheme.sun)
                            .frame(width: 46, height: 46)
                            .background(BotTheme.sunSoft, in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text(greeting).font(BotTheme.titleFont).foregroundStyle(BotTheme.ink)
                            Text(todayString).font(.subheadline).foregroundStyle(BotTheme.soft)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)

                    DailyLine()
                    RightNowCard()
                    SmallWinCard()
                    DoneForTodayCard()
                    intentionCard
                    ProgramCard()
                    if !store.state.settings.lists.morning.contains(where: { $0.id == "m_nick" }) {
                        nickLoadCard
                    }
                    section(title: "Morning", systemImage: "sun.max", items: store.state.settings.lists.morning, list: "morning")
                    section(title: "Daily anchors", systemImage: "leaf", items: store.state.settings.lists.anchors, list: "anchors")
                    HealthSummaryCard()
                    if store.state.settings.personalization?.supports.contains("pause") ?? true {
                        CodingPauseCard()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(BotTheme.cream.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { Task { await store.syncNow() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Sync now")
                }
                if !doneForToday {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(editing ? "Done" : "Edit") { editing.toggle() }
                            .font(.subheadline)
                    }
                }
            }
        }
        .tint(BotTheme.accent)
        .alert("Add a small task", isPresented: Binding(
            get: { addingTo != nil },
            set: { if !$0 { addingTo = nil } }
        )) {
            TextField("Task", text: $newTask)
            TextField("Smallest version (optional)", text: $newSmall)
            Button("Add") {
                if let list = addingTo { store.addTask(newTask, small: newSmall, to: list) }
                addingTo = nil
            }
            Button("Cancel", role: .cancel) { addingTo = nil }
        } message: {
            Text("Keep it small enough for a hard day.")
        }
        .alert("Remove from Home?", isPresented: Binding(
            get: { removing != nil },
            set: { if !$0 { removing = nil } }
        )) {
            Button("Move to Keep close", role: .destructive) {
                if let item = removing { store.removeTask(item.id, from: removeFrom) }
                removing = nil
            }
            Button("Keep it", role: .cancel) { removing = nil }
        } message: {
            Text("It will wait on the Keep close shelf. You can borrow it back later.")
        }
        .onAppear { intention = store.state.days[todayKey()]?.intention ?? "" }
    }

    private var intentionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(BotTheme.accent)
                Text("One intention")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
            }
            TextField("A word, a feeling, a direction…", text: $intention, axis: .vertical)
                .lineLimit(1...3)
                .foregroundStyle(BotTheme.ink)
                .onSubmit { saveIntention() }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(colors: [BotTheme.card, BotTheme.accentSoft.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(BotTheme.accent.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: BotTheme.accent.opacity(0.08), radius: 16, x: 0, y: 8)
    }

    private var nickLoadCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "headphones")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(BotTheme.accentGradient, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Nick Moss daily meditation")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
                Text("A gentle place to begin").font(.caption).foregroundStyle(BotTheme.soft)
            }
            Spacer()
            Button("Load in") { store.addNickToMorning() }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(BotTheme.accentGradient, in: Capsule())
                .buttonStyle(.plain)
        }
        .padding(16)
        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: BotTheme.ink.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    @ViewBuilder
    private func section(title: String, systemImage: String, items: [ListItem], list: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            BotSectionHeader(title: title, systemImage: systemImage)
                .padding(.horizontal, 4)
            VStack(spacing: 0) {
                if items.isEmpty {
                    Text("Nothing here yet.")
                        .font(.subheadline)
                        .foregroundStyle(BotTheme.soft)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(items) { item in
                        row(item, editMode: editing, onRemove: {
                            removing = item
                            removeFrom = list
                        })
                        if item.id != items.last?.id {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                if editing && !doneForToday {
                    Divider().padding(.leading, 52)
                    Button {
                        addingTo = list
                        newTask = ""
                        newSmall = ""
                    } label: {
                        Label("Add a small task", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BotTheme.accent)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, items.isEmpty ? 0 : 4)
            .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.line.opacity(0.35), lineWidth: 1))
            .shadow(color: BotTheme.ink.opacity(0.045), radius: 12, x: 0, y: 6)
        }
    }

    private func row(_ item: ListItem, editMode: Bool, onRemove: @escaping () -> Void) -> some View {
        let checked = store.state.days[todayKey()]?.checks[item.id] ?? false
        return HStack(alignment: .center, spacing: 12) {
            Button { toggle(item.id) } label: {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checked ? BotTheme.accent : BotTheme.soft)
            }
            .buttonStyle(.plain)
            .disabled(doneForToday)
            .opacity(doneForToday ? 0.6 : 1)
            .accessibilityLabel(item.text)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .foregroundStyle(BotTheme.ink)
                    .strikethrough(checked, color: BotTheme.soft)
                if let note = item.note, !note.isEmpty {
                    Text(note).font(.caption).foregroundStyle(BotTheme.soft)
                }
                DisclosureGroup("Even smaller") {
                    Text(item.small ?? "Just start with one small part.")
                        .font(.caption)
                        .foregroundStyle(BotTheme.soft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.caption)
                .foregroundStyle(BotTheme.soft)
            }

            if let urlString = item.url, let url = URL(string: urlString) {
                Link(destination: url) {
                    Label("Open", systemImage: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(BotTheme.accent.opacity(0.14), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            if editMode && !doneForToday {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle")
                        .foregroundStyle(BotTheme.soft)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Move \(item.text) to Keep close")
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func toggle(_ id: String) {
        let today = todayKey()
        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
        let newValue = !(store.state.days[today]?.checks[id] ?? false)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            store.state.days[today]?.checks[id] = newValue
        }
        store.save()
        Haptics.tap()
        if newValue { whisper.show() }
    }

    private func saveIntention() {
        let today = todayKey()
        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
        store.state.days[today]?.intention = intention
        store.save()
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning." }
        if h < 17 { return "Good afternoon." }
        return "Good evening."
    }

    private var todayString: String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: Date())
    }
}

func todayKey() -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f.string(from: Date())
}