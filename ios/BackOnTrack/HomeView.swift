import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var intention: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(greeting).font(.title2).bold()
                    Text(todayString).font(.caption).foregroundStyle(.secondary)

                    if !store.state.settings.program30.loaded {
                        Text("A quiet 30 days is here, if you want it.")
                            .font(.footnote).foregroundStyle(.secondary).underline()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("One intention").font(.headline)
                        TextField("One intention", text: $intention)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { saveIntention() }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                    section(title: "Morning", items: store.state.settings.lists.morning)
                    section(title: "Daily anchors", items: store.state.settings.lists.anchors)
                }
                .padding()
            }
            .navigationTitle("Home")
        }
        .onAppear {
            let today = todayKey()
            intention = store.state.days[today]?.intention ?? ""
        }
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning." }
        if h < 17 { return "Good afternoon." }
        return "Good evening."
    }
    private var todayString: String {
        let f = DateFormatter(); f.dateStyle = .full
        return f.string(from: Date())
    }
    private func saveIntention() {
        let today = todayKey()
        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
        store.state.days[today]?.intention = intention
        store.save()
    }
    @ViewBuilder
    private func section(title: String, items: [ListItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if items.isEmpty {
                Text("Nothing here yet.").font(.caption).foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: "circle")
                        Text(item.text)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

func todayKey() -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f.string(from: Date())
}