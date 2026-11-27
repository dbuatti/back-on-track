import SwiftUI

private enum Cozy {
    static let bg = Color(red: 0.141, green: 0.102, blue: 0.227)
    static let card = Color(red: 0.180, green: 0.137, blue: 0.314)
    static let card2 = Color(red: 0.227, green: 0.173, blue: 0.388)
    static let ink = Color(red: 0.969, green: 0.949, blue: 1.0)
    static let soft = Color(red: 0.796, green: 0.722, blue: 0.910)
    static let accent = Color(red: 0.749, green: 0.655, blue: 0.961)
    static let line = Color(red: 0.290, green: 0.227, blue: 0.463)
}

struct CozyTimeView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @State private var showingDump = false

    private let starter = [
        "Fold clothes",
        "Piano practice & gig preparation",
        "Write a piece of music",
        "Journal",
        "Study",
        "A short walk or stretch",
        "Tidy one surface",
        "Reply to one message"
    ]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let ct = store.state.settings.cozyTimer ?? CozyTimerState()
            let remaining = store.cozyRemaining(now: context.date)
            ZStack {
                LinearGradient(colors: [Cozy.card, Cozy.bg], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        hero(ct: ct, remaining: remaining, date: context.date)
                        possibilities(ct: ct)
                        settingsCard(ct: ct)
                    }
                    .padding(18)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }
                .scrollContentBackground(.hidden)
            }
            .onAppear { store.creditCozy() }
            .fullScreenCover(isPresented: $showingDump) {
                VoiceDumpView()
                    .environmentObject(store)
                    .environmentObject(whisper)
            }
        }
    }

    private func meter(fraction: CGFloat) -> some View {
        let colors: [Color] = fraction > 0.66
            ? [Color(red: 0.847, green: 0.769, blue: 1.0), Color(red: 0.561, green: 0.435, blue: 0.816)]
            : fraction > 0.33
                ? [Color(red: 0.804, green: 0.851, blue: 1.0), Color(red: 0.435, green: 0.514, blue: 0.812)]
                : [Color(red: 1.0, green: 0.863, blue: 0.769), Color(red: 0.843, green: 0.541, blue: 0.388)]
        return ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Cozy.card2)
                .frame(width: 78, height: 260)
                .overlay(RoundedRectangle(cornerRadius: 36, style: .continuous).stroke(Cozy.line, lineWidth: 1))
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                .frame(width: 78, height: 260 * fraction)
                .animation(.linear(duration: 0.6), value: fraction)
            VStack {
                Spacer()
                ForEach(0..<5, id: \.self) { _ in
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.28)).frame(width: 22, height: 1)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 14)
            .padding(.leading, 12)
            HStack {
                Rectangle()
                    .fill(LinearGradient(colors: [Color.white.opacity(0.26), Color.white.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 10)
                    .padding(.vertical, 14)
                Spacer()
            }
            .padding(.leading, 12)
        }
        .frame(width: 78, height: 260)
        .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 8)
    }

    private func hero(ct: CozyTimerState, remaining: Double, date: Date) -> some View {
        let total = max(ct.dailyMinutes, ct.remainingAtStart)
        let fraction = max(0, min(1, remaining / total))
        let mins = Int(remaining)
        let secs = Int((remaining - Double(mins)) * 60)
        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TIME, GENTLY")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(Cozy.accent)
                    Text("A little time, if you want it.")
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Cozy.ink)
                }
                Spacer()
            }
            Text("This is not a restriction. It just makes the time visible while you do the thing you enjoy.")
                .font(.subheadline)
                .foregroundStyle(Cozy.soft)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center, spacing: 26) {
                meter(fraction: fraction)
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%02d:%02d", mins, secs))
                        .font(.system(size: 46, weight: .light, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(Cozy.ink)
                    Text(ct.active ? "still here" : "minutes left")
                        .font(.caption)
                        .foregroundStyle(Cozy.soft)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)

            HStack(spacing: 10) {
                if !ct.active {
                    Button("Begin gently") {
                        store.startCozy()
                        Haptics.gentle()
                        whisper.show("your time.")
                    }
                    .cozyPrimary()
                    .disabled(ct.bankedMinutes <= 0)
                } else {
                    Button("Pause") {
                        store.stopCozy(finished: false)
                        Haptics.gentle()
                    }
                    .cozyGhost()
                }
                if remaining <= 0 && !ct.active {
                    Button("Close") {
                        store.stopCozy(finished: true)
                        Haptics.gentle()
                    }
                    .cozyGhost()
                }
            }

            Text(message(ct: ct, remaining: remaining))
                .font(.caption)
                .foregroundStyle(Cozy.soft)
                .multilineTextAlignment(.center)
                .frame(minHeight: 32)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Cozy.card, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Cozy.line, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 10)
    }

    private func possibilities(ct: CozyTimerState) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THINGS YOU COULD BE DOING RIGHT NOW")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Cozy.accent)
            Text("Not a to-do list. Just a reminder that these exist, even when you forget.")
                .font(.subheadline)
                .foregroundStyle(Cozy.soft)
            VStack(spacing: 0) {
                ForEach(starter + ct.custom, id: \.self) { item in
                    HStack {
                        Text(item.uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(0.7)
                            .foregroundStyle(Cozy.ink)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Cozy.card2.opacity(0.55), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Cozy.accent.opacity(0.16), lineWidth: 1))
    }

    private func settingsCard(ct: CozyTimerState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily minutes")
                    .foregroundStyle(Cozy.soft)
                Spacer()
                Picker("Daily minutes", selection: Binding(
                    get: { Int(ct.dailyMinutes) },
                    set: { store.setCozyDaily(Double($0)) }
                )) {
                    ForEach([15, 20, 30, 45, 60], id: \.self) { Text(String($0)).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Cozy.accent)
            }
            Text("You have \(Int(ct.bankedMinutes)) minutes available. Unused minutes roll over — there is no cap and no score.")
                .font(.caption)
                .foregroundStyle(Cozy.soft)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Cozy.card, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Cozy.line, lineWidth: 1))
    }

    private func message(ct: CozyTimerState, remaining: Double) -> String {
        if ct.active {
            let spent = max(0, ct.remainingAtStart - remaining)
            return "You've been here about \(Int(spent)) minutes. No need to feel anything about it."
        }
        if remaining <= 0 {
            return "That's your time for now. The things below are still here whenever you want them."
        }
        return "Unused time waits here for you. Nothing is lost."
    }
}

private extension View {
    func cozyPrimary() -> some View {
        self.font(.subheadline.weight(.semibold))
            .foregroundStyle(Cozy.bg)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(Cozy.accent, in: Capsule())
            .buttonStyle(.plain)
    }
    func cozyGhost() -> some View {
        self.font(.subheadline.weight(.semibold))
            .foregroundStyle(Cozy.ink)
            .padding(.horizontal, 18)
            .frame(height: 48)
            .background(Color.clear, in: Capsule())
            .overlay(Capsule().stroke(Cozy.line, lineWidth: 1))
            .buttonStyle(.plain)
    }
}
