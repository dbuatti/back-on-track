import SwiftUI
import UIKit

private func dyn(_ light: UIColor, _ dark: UIColor) -> Color {
    Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? dark : light
    })
}

enum BotTheme {
    static let cream = dyn(UIColor(red: 0.969, green: 0.937, blue: 0.886, alpha: 1),
                           UIColor(red: 0.125, green: 0.106, blue: 0.094, alpha: 1))
    static let card = dyn(UIColor(red: 1.0, green: 0.984, blue: 0.953, alpha: 1),
                          UIColor(red: 0.165, green: 0.141, blue: 0.125, alpha: 1))
    static let field = dyn(UIColor(red: 1.0, green: 1.0, blue: 0.976, alpha: 1),
                           UIColor(red: 0.200, green: 0.173, blue: 0.153, alpha: 1))
    static let ink = dyn(UIColor(red: 0.227, green: 0.184, blue: 0.157, alpha: 1),
                         UIColor(red: 0.957, green: 0.925, blue: 0.886, alpha: 1))
    static let soft = dyn(UIColor(red: 0.416, green: 0.353, blue: 0.290, alpha: 1),
                          UIColor(red: 0.800, green: 0.737, blue: 0.671, alpha: 1))
    static let line = dyn(UIColor(red: 0.910, green: 0.851, blue: 0.784, alpha: 1),
                          UIColor(red: 0.275, green: 0.231, blue: 0.204, alpha: 1))
    static let accent = dyn(UIColor(red: 0.788, green: 0.416, blue: 0.290, alpha: 1),
                            UIColor(red: 0.910, green: 0.627, blue: 0.498, alpha: 1))
    static let accentDeep = dyn(UIColor(red: 0.604, green: 0.290, blue: 0.188, alpha: 1),
                                UIColor(red: 0.949, green: 0.753, blue: 0.659, alpha: 1))
    static let accentSoft = dyn(UIColor(red: 0.949, green: 0.878, blue: 0.847, alpha: 1),
                                UIColor(red: 0.275, green: 0.192, blue: 0.153, alpha: 1))
    static let sun = dyn(UIColor(red: 0.878, green: 0.659, blue: 0.353, alpha: 1),
                         UIColor(red: 0.847, green: 0.643, blue: 0.416, alpha: 1))
    static let sunSoft = dyn(UIColor(red: 0.965, green: 0.902, blue: 0.784, alpha: 1),
                             UIColor(red: 0.275, green: 0.200, blue: 0.149, alpha: 1))
    static let evening = dyn(UIColor(red: 0.604, green: 0.498, blue: 0.690, alpha: 1),
                             UIColor(red: 0.710, green: 0.655, blue: 0.816, alpha: 1))
    static let eveningSoft = dyn(UIColor(red: 0.925, green: 0.894, blue: 0.949, alpha: 1),
                                 UIColor(red: 0.220, green: 0.184, blue: 0.271, alpha: 1))
    static let sage = dyn(UIColor(red: 0.435, green: 0.561, blue: 0.463, alpha: 1),
                          UIColor(red: 0.561, green: 0.682, blue: 0.588, alpha: 1))
    static let sageSoft = dyn(UIColor(red: 0.878, green: 0.914, blue: 0.863, alpha: 1),
                              UIColor(red: 0.188, green: 0.247, blue: 0.204, alpha: 1))

    static let backgroundTop = dyn(UIColor(red: 0.985, green: 0.963, blue: 0.925, alpha: 1),
                                   UIColor(red: 0.141, green: 0.114, blue: 0.102, alpha: 1))
    static let backgroundBottom = dyn(UIColor(red: 0.953, green: 0.910, blue: 0.875, alpha: 1),
                                      UIColor(red: 0.098, green: 0.082, blue: 0.098, alpha: 1))

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)

    static func ui(_ light: UIColor, _ dark: UIColor) -> UIColor {
        UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, cream, backgroundBottom], startPoint: .top, endPoint: .bottom)
    }

    static var accentGradient: LinearGradient {
        LinearGradient(colors: [accent, accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var eveningGradient: LinearGradient {
        LinearGradient(colors: [eveningSoft, evening.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    .stroke(BotTheme.line.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: BotTheme.ink.opacity(0.06), radius: 14, x: 0, y: 7)
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
