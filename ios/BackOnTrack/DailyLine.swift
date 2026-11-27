import SwiftUI

struct DailyLine: View {
    private let lines = [
        "Begin gently.",
        "There is no hurry.",
        "One thing at a time is enough.",
        "Come back to the body.",
        "You can start small.",
        "Quiet is allowed.",
        "Let it be easy.",
        "Nothing to prove today.",
        "Soft is a strength.",
        "You can begin again.",
        "A little is plenty.",
        "The day can be kind."
    ]

    private var line: String {
        let key = todayKey()
        let hash = key.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return lines[hash % lines.count]
    }

    var body: some View {
        Text(line)
            .font(.system(.subheadline, design: .serif).italic())
            .foregroundStyle(BotTheme.soft)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .accessibilityLabel("Today's quiet line: \(line)")
    }
}
