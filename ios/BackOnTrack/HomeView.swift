import SwiftUI

private let botCream = Color(red: 0.969, green: 0.937, blue: 0.886)
private let botCard = Color(red: 1.0, green: 0.984, blue: 0.953)
private let botInk = Color(red: 0.227, green: 0.184, blue: 0.157)
private let botSoft = Color(red: 0.416, green: 0.353, blue: 0.290)
private let botAccent = Color(red: 0.788, green: 0.416, blue: 0.290)

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var intention: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting).font(.largeTitle).bold()
                        Text(todayString).font(.subheadline).foregroundStyle(botSoft)
                    }
                    .padding(.horizontal, 4)

                    intentionCard
                    if !store.state.settings.lists.morning.contains(where: { $0.id == "m_nick" }) {
                        nickLoadCard
                    }
                    section(title: "Morning", systemImage: "sun.max", items: store.state.settings.lists.morning)
                    section(title: "Daily anchors", systemImage: "leaf", items: store.state.settings.lists.anchors)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(botCream.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(botAccent)
        .onAppear { intention = store.state.days[todayKey()]?.intention ?? "" }
    }

    private var intentionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("One intention", systemImage: "sparkles")
                .font(.headline)
            TextField("A word, a feeling, a direction…", text: $intention, axis: .vertical)
                .lineLimit(1...3)
                .onSubmit { saveIntention() }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(botCard, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var nickLoadCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "headphones")
                .font(.title2)
                .foregroundStyle(botAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Nick Moss daily meditation").font(.headline)
                Text("A gentle place to begin").font(.caption).foregroundStyle(botSoft)
            }
            Spacer()
            Button("Load in") { store.addNickToMorning() }
                .buttonStyle(.bordered)
                .tint(botAccent)
        }
        .padding(16)
        .background(botCard, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private func section(title: String, systemImage: String, items: [ListItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding(.horizontal, 4)
            if items.isEmpty {
                Text("Nothing here yet.")
                    .font(.subheadline)
                    .foregroundStyle(botSoft)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(botCard, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        row(item)
                        if item.id != items.last?.id {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .background(botCard, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
    }

    private func row(_ item: ListItem) -> some View {
        let checked = store.state.days[todayKey()]?.checks[item.id] ?? false
        return HStack(alignment: .center, spacing: 12) {
            Button { toggle(item.id) } label: {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checked ? botAccent : botSoft)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.text)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .foregroundStyle(botInk)
                    .strikethrough(checked, color: botSoft)
                if let note = item.note, !note.isEmpty {
                    Text(note).font(.caption).foregroundStyle(botSoft)
                }
                DisclosureGroup("Even smaller") {
                    Text(item.small ?? "Just start with one small part.")
                        .font(.caption)
                        .foregroundStyle(botSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.caption)
                .foregroundStyle(botSoft)
            }

            if let urlString = item.url, let url = URL(string: urlString) {
                Link(destination: url) {
                    Label("Open", systemImage: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(botAccent.opacity(0.14), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func toggle(_ id: String) {
        let today = todayKey()
        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
        store.state.days[today]?.checks[id] = !(store.state.days[today]?.checks[id] ?? false)
        store.save()
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