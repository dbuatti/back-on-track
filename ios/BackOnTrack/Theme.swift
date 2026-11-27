import SwiftUI

enum BotTheme {
    static let cream = Color(red: 0.969, green: 0.937, blue: 0.886)
    static let card = Color(red: 1.0, green: 0.984, blue: 0.953)
    static let field = Color(red: 1.0, green: 1.0, blue: 0.976)
    static let ink = Color(red: 0.227, green: 0.184, blue: 0.157)
    static let soft = Color(red: 0.416, green: 0.353, blue: 0.290)
    static let line = Color(red: 0.910, green: 0.851, blue: 0.784)
    static let accent = Color(red: 0.788, green: 0.416, blue: 0.290)
    static let accentDeep = Color(red: 0.604, green: 0.290, blue: 0.188)
    static let accentSoft = Color(red: 0.949, green: 0.878, blue: 0.847)
    static let sun = Color(red: 0.878, green: 0.659, blue: 0.353)
    static let sunSoft = Color(red: 0.965, green: 0.902, blue: 0.784)
    static let evening = Color(red: 0.604, green: 0.498, blue: 0.690)
    static let eveningSoft = Color(red: 0.925, green: 0.894, blue: 0.949)
    static let sage = Color(red: 0.435, green: 0.561, blue: 0.463)
    static let sageSoft = Color(red: 0.878, green: 0.914, blue: 0.863)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.985, green: 0.963, blue: 0.925),
                cream,
                Color(red: 0.953, green: 0.910, blue: 0.875)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.843, green: 0.486, blue: 0.337), accentDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var eveningGradient: LinearGradient {
        LinearGradient(
            colors: [eveningSoft, Color(red: 0.890, green: 0.843, blue: 0.925)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct BotCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(BotTheme.line.opacity(0.40), lineWidth: 1)
            )
            .shadow(color: BotTheme.ink.opacity(0.055), radius: 14, x: 0, y: 7)
    }
}

struct BotSectionHeader: View {
    let title: String
    let systemImage: String
    var tint: Color = BotTheme.accent

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: Circle())
            Text(title)
                .font(BotTheme.headingFont)
                .foregroundStyle(BotTheme.ink)
        }
    }
}

extension View {
    func botCard() -> some View { modifier(BotCard()) }

    func botBackground() -> some View {
        ZStack {
            BotTheme.backgroundGradient.ignoresSafeArea()
            self
        }
        .tint(BotTheme.accent)
    }
}
