import SwiftUI

enum BotTheme {
    static let cream = Color(red: 0.969, green: 0.937, blue: 0.886)
    static let card = Color(red: 1.0, green: 0.984, blue: 0.953)
    static let field = Color(red: 1.0, green: 1.0, blue: 0.976)
    static let ink = Color(red: 0.227, green: 0.184, blue: 0.157)
    static let soft = Color(red: 0.416, green: 0.353, blue: 0.290)
    static let line = Color(red: 0.910, green: 0.851, blue: 0.784)
    static let accent = Color(red: 0.788, green: 0.416, blue: 0.290)
    static let accentSoft = Color(red: 0.949, green: 0.878, blue: 0.847)
    static let sun = Color(red: 0.878, green: 0.659, blue: 0.353)
    static let evening = Color(red: 0.604, green: 0.498, blue: 0.690)
}

struct BotCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(BotTheme.line.opacity(0.45), lineWidth: 1)
            )
    }
}

extension View {
    func botCard() -> some View { modifier(BotCard()) }
    func botBackground() -> some View {
        background(BotTheme.cream.ignoresSafeArea())
            .tint(BotTheme.accent)
    }
}