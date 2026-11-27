import SwiftUI

struct CodingPauseCard: View {
    @EnvironmentObject var store: AppStore
    @State private var showingPause = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pause.circle")
                .font(.title2)
                .foregroundStyle(BotTheme.evening)
                .frame(width: 42, height: 42)
                .background(BotTheme.eveningSoft, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Coding pulling you in?")
                    .font(BotTheme.headingFont)
                    .foregroundStyle(BotTheme.ink)
                Text("A 60-second way to stop gently.")
                    .font(.caption).foregroundStyle(BotTheme.soft)
            }
            Spacer()
            Button("Pause") { showingPause = true }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(BotTheme.evening, in: Capsule())
                .buttonStyle(.plain)
        }
        .padding(16)
        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.evening.opacity(0.14), lineWidth: 1))
        .shadow(color: BotTheme.evening.opacity(0.07), radius: 14, x: 0, y: 7)
        .sheet(isPresented: $showingPause) {
            CodingPauseSheet()
                .environmentObject(store)
        }
    }
}

struct CodingPauseSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var remaining = 60
    @State private var running = false
    @State private var nextStep = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Text("You can stop here.")
                        .font(BotTheme.titleFont)
                        .foregroundStyle(BotTheme.ink)
                        .multilineTextAlignment(.center)
                    Text("Nothing needs to be finished in this minute.")
                        .font(.subheadline)
                        .foregroundStyle(BotTheme.soft)
                        .multilineTextAlignment(.center)

                    ZStack {
                        Circle()
                            .stroke(BotTheme.eveningSoft, lineWidth: 12)
                        Circle()
                            .trim(from: 0, to: CGFloat(remaining) / 60)
                            .stroke(BotTheme.evening, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.3), value: remaining)
                        VStack(spacing: 4) {
                            Text("\(remaining)")
                                .font(.system(size: 48, weight: .light, design: .rounded))
                                .foregroundStyle(BotTheme.ink)
                                .monospacedDigit()
                            Text("seconds")
                                .font(.caption).foregroundStyle(BotTheme.soft)
                        }
                    }
                    .frame(width: 180, height: 180)
                    .padding(.top, 6)

                    Button(running ? "Pause" : (remaining == 60 ? "Begin" : "Continue")) {
                        running.toggle()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(BotTheme.evening, in: Capsule())
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 14) {
                        groundingRow("Feet on the floor", "Notice the chair holding you.")
                        groundingRow("One slow breath", "Let it out a little longer.")
                        groundingRow("Look away", "Find one thing that isn't a screen.")
                        groundingRow("Close the editor", "The code will still be there.")
                    }
                    .botCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("One next step, then stop")
                            .font(BotTheme.headingFont)
                            .foregroundStyle(BotTheme.ink)
                        TextField("e.g. tomorrow: check the login error", text: $nextStep, axis: .vertical)
                            .lineLimit(1...3)
                            .textFieldStyle(.roundedBorder)
                        Text("Optional. Saving this is enough — no need to act on it now.")
                            .font(.caption).foregroundStyle(BotTheme.soft)
                    }
                    .botCard()

                    Button("Save next step & close") {
                        let today = todayKey()
                        if store.state.days[today] == nil { store.state.days[today] = DayRecord.empty(today) }
                        store.state.days[today]?.codingNextStep = nextStep.trimmingCharacters(in: .whitespacesAndNewlines)
                        store.save()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(BotTheme.accentGradient, in: Capsule())
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .botBackground()
            .navigationTitle("Coding pause")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            nextStep = store.state.days[todayKey()]?.codingNextStep ?? ""
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard running, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 { running = false }
        }
    }

    private func groundingRow(_ title: String, _ detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .foregroundStyle(BotTheme.evening)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(BotTheme.ink)
                Text(detail).font(.caption).foregroundStyle(BotTheme.soft)
            }
        }
    }
}