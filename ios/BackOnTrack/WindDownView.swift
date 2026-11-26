import SwiftUI

struct WindDownView: View {
    @EnvironmentObject var store: AppStore
    @State private var bedTime: String = ""
    @State private var wakeTime: String = ""
    @State private var mood: String = "okay"
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Last night") {
                    TextField("Bedtime (HH:MM)", text: $bedTime)
                    TextField("Wake (HH:MM)", text: $wakeTime)
                }
                Section("Mood") {
                    Picker("Mood", selection: $mood) {
                        Text("Low").tag("low")
                        Text("Okay").tag("okay")
                        Text("Good").tag("good")
                    }.pickerStyle(.segmented)
                }
                Section("Note on waking") {
                    TextEditor(text: $note).frame(minHeight: 80)
                }
                Section {
                    Button("Save") { save() }
                }
            }
            .navigationTitle("Wind down")
        }
        .onAppear { load() }
    }

    private func load() {
        let today = todayKey()
        let rec = store.state.days[today] ?? DayRecord.empty(today)
        bedTime = rec.bedTime ?? ""
        wakeTime = rec.wakeTime ?? ""
        mood = rec.mood ?? "okay"
        note = rec.note
    }
    private func save() {
        let today = todayKey()
        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
        store.state.days[today]?.bedTime = bedTime.isEmpty ? nil : bedTime
        store.state.days[today]?.wakeTime = wakeTime.isEmpty ? nil : wakeTime
        store.state.days[today]?.mood = mood
        store.state.days[today]?.note = note
        store.save()
    }
}