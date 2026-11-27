import SwiftUI

struct WindDownView: View {
    @EnvironmentObject var store: AppStore
    @State private var bedDate = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date()) ?? Date()
    @State private var wakeDate = Date()
    @State private var mood = "okay"
    @State private var note = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wind down").font(.largeTitle).bold().foregroundStyle(BotTheme.ink)
                        Text("One small thing at a time.").font(.subheadline).foregroundStyle(BotTheme.soft)
                    }

                    if let rec = store.state.days[todayKey()], rec.bedTime != nil || rec.wakeTime != nil {
                        lastNightCard(rec)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sleep", systemImage: "moon.stars")
                            .font(.headline).foregroundStyle(BotTheme.ink)
                        timeCard(
                            title: "Bedtime",
                            systemImage: "bed.double",
                            date: $bedDate,
                            value: store.state.days[todayKey()]?.bedTime,
                            action: logBedNow
                        )
                        timeCard(
                            title: "Wake time",
                            systemImage: "sunrise",
                            date: $wakeDate,
                            value: store.state.days[todayKey()]?.wakeTime,
                            action: logWakeNow
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("How it felt", systemImage: "heart")
                            .font(.headline).foregroundStyle(BotTheme.ink)
                        Picker("Mood", selection: $mood) {
                            Text("Low").tag("low")
                            Text("Okay").tag("okay")
                            Text("Good").tag("good")
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: mood) { _, _ in saveMoodAndNote() }
                    }
                    .botCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Label("A note on waking", systemImage: "note.text")
                            .font(.headline).foregroundStyle(BotTheme.ink)
                        TextEditor(text: $note)
                            .frame(minHeight: 96)
                            .padding(8)
                            .background(BotTheme.field, in: RoundedRectangle(cornerRadius: 12))
                            .onChange(of: note) { _, _ in saveMoodAndNote() }
                    }
                    .botCard()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .botBackground()
            .navigationTitle("Wind down")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: load)
    }

    private func timeCard(title: String, systemImage: String, date: Binding<Date>, value: String?, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(BotTheme.evening)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline).foregroundStyle(BotTheme.ink)
                    Text(value ?? "Not logged")
                        .font(.caption)
                        .foregroundStyle(BotTheme.soft)
                }
                Spacer()
                Button(action: action) {
                    Text("Log now")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(BotTheme.accent, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            DisclosureGroup("Adjust time") {
                DatePicker(title, selection: date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxHeight: 140)
                    .onChange(of: date.wrappedValue) { _, _ in
                        if title == "Bedtime" { saveBedDate() } else { saveWakeDate() }
                    }
            }
            .font(.caption)
            .foregroundStyle(BotTheme.soft)
        }
        .botCard()
    }

    private func lastNightCard(_ rec: DayRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(BotTheme.evening)
            VStack(alignment: .leading, spacing: 4) {
                Text("Last night").font(.headline).foregroundStyle(BotTheme.ink)
                Text([rec.bedTime, rec.wakeTime].compactMap { $0 }.joined(separator: "  →  "))
                    .font(.subheadline).foregroundStyle(BotTheme.soft)
            }
            Spacer()
        }
        .botCard()
    }

    private func load() {
        let rec = store.state.days[todayKey()] ?? DayRecord.empty(todayKey())
        bedDate = date(from: rec.bedTime) ?? bedDate
        wakeDate = date(from: rec.wakeTime) ?? wakeDate
        mood = rec.mood ?? "okay"
        note = rec.note
    }

    private func logBedNow() {
        bedDate = Date()
        saveBedDate()
    }

    private func logWakeNow() {
        wakeDate = Date()
        saveWakeDate()
    }

    private func saveBedDate() {
        ensureDay()
        store.state.days[todayKey()]?.bedTime = timeString(bedDate)
        store.save()
    }

    private func saveWakeDate() {
        ensureDay()
        store.state.days[todayKey()]?.wakeTime = timeString(wakeDate)
        store.save()
    }

    private func saveMoodAndNote() {
        ensureDay()
        store.state.days[todayKey()]?.mood = mood
        store.state.days[todayKey()]?.note = note
        store.save()
    }

    private func ensureDay() {
        if store.state.days[todayKey()] == nil {
            store.state.days[todayKey()] = DayRecord.empty(todayKey())
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func date(from value: String?) -> Date? {
        guard let value else { return nil }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.date(from: value)
    }
}