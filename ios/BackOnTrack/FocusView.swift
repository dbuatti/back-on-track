import SwiftUI

struct FocusView: View {
    @State private var index = 0
    private let sections: [FocusSection] = [
        FocusSection(title: "Morning", icon: "sun.max", line: "Begin gently. Nothing needs to be perfect."),
        FocusSection(title: "Daily anchors", icon: "leaf", line: "One thing that keeps the day steady."),
        FocusSection(title: "Instead of gaming", icon: "gamecontroller", line: "A softer way to land in the evening.")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: sections[index].icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(BotTheme.accent)

                Text(sections[index].title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(BotTheme.ink)
                    .multilineTextAlignment(.center)

                Text(sections[index].line)
                    .font(.body)
                    .foregroundStyle(BotTheme.soft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                HStack(spacing: 8) {
                    ForEach(0..<sections.count, id: \.self) { i in
                        Circle()
                            .fill(i == index ? BotTheme.accent : BotTheme.line)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)

                Spacer()

                HStack(spacing: 12) {
                    Button { if index > 0 { index -= 1 } } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .frame(width: 52, height: 52)
                            .background(BotTheme.card, in: Circle())
                            .foregroundStyle(BotTheme.ink)
                    }
                    .buttonStyle(.plain)
                    .disabled(index == 0)

                    Button { finish() } label: {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(BotTheme.accent, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    Button { if index < sections.count - 1 { index += 1 } } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .frame(width: 52, height: 52)
                            .background(BotTheme.card, in: Circle())
                            .foregroundStyle(BotTheme.ink)
                    }
                    .buttonStyle(.plain)
                    .disabled(index == sections.count - 1)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .botBackground()
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func finish() {
        index = 0
    }
}

private struct FocusSection {
    let title: String
    let icon: String
    let line: String
}