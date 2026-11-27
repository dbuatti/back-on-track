import SwiftUI

private struct SleepNight: Identifiable {
    let id: String
    let date: Date
    let bed: String
    let wake: String
    let minutes: Int
    let mood: String?
}

struct SleepTrendCard: View {
    @EnvironmentObject var store: AppStore

    private var nights: [SleepNight] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return store.state.days.values.compactMap { day -> SleepNight? in
            guard let bed = day.bedTime, let wake = day.wakeTime,
                  let date = formatter.date(from: day.date) else { return nil }
            return SleepNight(id: day.date, date: date, bed: bed, wake: wake, minutes: duration(bed: bed, wake: wake), mood: day.mood)
        }
        .sorted { $0.date > $1.date }
        .prefix(14)
        .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BotSectionHeader(title: "A soft sleep pattern", systemImage: "chart.line.uptrend.xyaxis", tint: BotTheme.evening)

            if nights.isEmpty {
                Text("Log a few bed and wake times. A gentle pattern will appear here — never a score.")
                    .font(.subheadline).foregroundStyle(BotTheme.soft)
            } else {
                if nights.count >= 3 {
                    Text(summary)
                        .font(.caption).foregroundStyle(BotTheme.soft)
                }

                VStack(spacing: 10) {
                    ForEach(nights.prefix(7)) { night in
                        HStack(spacing: 10) {
                            Text(dayLabel(night.date))
                                .font(.caption2)
                                .foregroundStyle(BotTheme.soft)
                                .frame(width: 34, alignment: .leading)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(night.bed)  →  \(night.wake)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(BotTheme.ink)
                                    .monospacedDigit()
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(BotTheme.eveningSoft)
                                        Capsule()
                                            .fill(BotTheme.evening.opacity(0.65))
                                            .frame(width: geo.size.width * barFraction(night.minutes))
                                    }
                                }
                                .frame(height: 5)
                            }
                            Text(durationLabel(night.minutes))
                                .font(.caption2)
                                .foregroundStyle(BotTheme.soft)
                                .monospacedDigit()
                                .frame(width: 42, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .botCard()
    }

    private var summary: String {
        let values = nights.map(\.minutes).sorted()
        let median = values[values.count / 2]
        return "The middle night is about \(durationLabel(median)). This is just a soft pattern, not a target."
    }

    private func duration(bed: String, wake: String) -> Int {
        let b = minutes(bed)
        var w = minutes(wake)
        if w <= b { w += 24 * 60 }
        return max(0, w - b)
    }

    private func minutes(_ value: String) -> Int {
        let parts = value.split(separator: ":").compactMap { Int($0) }
        guard parts.count >= 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }

    private func durationLabel(_ value: Int) -> String {
        "\(value / 60)h \(value % 60)m"
    }

    private func barFraction(_ value: Int) -> CGFloat {
        CGFloat(max(0.12, min(1, Double(value) / (12 * 60))))
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: date)
    }
}
