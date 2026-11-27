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
                    HStack(spacing: 14) {
                        Image(systemName: "moon.stars.fill")
                            .font(.title2)
                            .foregroundStyle(BotTheme.evening)
                            .frame(width: 46, height: 46)
                            .background(BotTheme.eveningSoft, in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Wind down").font(BotTheme.titleFont).foregroundStyle(BotTheme.ink)
                            Text("One small thing at a time.").font(.subheadline).foregroundStyle(BotTheme.soft)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)

                    HStack(spacing: 12) {
                        Image(systemName: "leaf")
                            .foregroundStyle(BotTheme.evening)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Let the day be enough.")
                                .font(BotTheme.headingFont)
                                .foregroundStyle(BotTheme.ink)
                            Text("Nothing to catch up on.").font(.caption).foregroundStyle(BotTheme.soft)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(BotTheme.eveningGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.evening.opacity(0.12), lineWidth: 1))
                    .shadow(color: BotTheme.evening.opacity(0.08), radius: 16, x: 0, y: 8)

                    ProgramCard()

                    if let rec = store.state.days[todayKey()], rec.bedTime != nil || rec.wakeTime != nil {
                        lastNightCard(rec)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        BotSectionHeader(title: "Sleep", systemImage: "moon.stars", tint: BotTheme.evening)
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
                        BotSectionHeader(title: "Instead of gaming", systemImage: "gamecontroller", tint: BotTheme.evening)
                        VStack(spacing: 0) {
                            ForEach(store.state.settings.lists.instead) { item in
                                HStack(spacing: 12) {
                                    Button { toggle(item.id) } label: {
                                        Image(systemName: (store.state.days[todayKey()]?.checks[item.id] ?? false) ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle((store.state.days[todayKey()]?.checks[item.id] ?? false) ? BotTheme.accent : BotTheme.soft)
                                    }
                                    .buttonStyle(.plain)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.text).font(.subheadline).foregroundStyle(BotTheme.ink)
                                        DisclosureGroup("Even smaller") {
                                            Text(item.small ?? "Just the smallest part.")
                                                .font(.caption).foregroundStyle(BotTheme.soft)
                                        }
                                        .font(.caption).foregroundStyle(BotTheme.soft)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                if item.id != store.state.settings.lists.instead.last?.id { Divider() }
                            }
                        }
                    }
                    .botCard()

                    VStack(alignment: .leading, spacing: 8) {
                        BotSectionHeader(title: "How it felt", systemImage: "heart", tint: BotTheme.evening)
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
                        BotSectionHeader(title: "A note on waking", systemImage: "note.text", tint: BotTheme.evening)
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(BotTheme.evening)
                    .frame(width: 36, height: 36)
                    .background(BotTheme.eveningSoft, in: Circle())
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
                        .background(BotTheme.accentGradient, in: Capsule())
                        .foregroundStyle(.white)
                        .shadow(color: BotTheme.accent.opacity(0.18), radius: 7, x: 0, y: 4)
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

    private func toggle(_ id: String) {
        ensureDay()
        let current = store.state.days[todayKey()]?.checks[id] ?? false
        store.state.days[todayKey()]?.checks[id] = !current
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