import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var auth: AuthManager

    @State private var step = 0
    @State private var focusArea = "none"
    @State private var customFocus = ""
    @State private var supports: Set<String> = ["pause", "smallSteps"]
    @State private var starterSet = "gentle"

    private let focusOptions = [
        ("coding", "Coding / AI", "laptopcomputer"),
        ("gaming", "Gaming", "gamecontroller"),
        ("scrolling", "Scrolling", "rectangle.stack"),
        ("shopping", "Shopping", "bag"),
        ("food", "Food", "fork.knife"),
        ("other", "Something else", "ellipsis"),
        ("none", "Nothing specific", "leaf")
    ]

    private let supportOptions = [
        ("pause", "A 60-second pause", "One minute to stop gently.", "pause.circle"),
        ("smallSteps", "Smallest steps", "Every task can shrink.", "minus.circle"),
        ("sleep", "Sleep logging", "Bed, wake and a soft pattern.", "moon.stars"),
        ("evening", "Evening alternatives", "Gentler things to do instead.", "gamecontroller"),
        ("movement", "Movement", "Small walks and stretches.", "figure.walk"),
        ("selfreg", "Self-regulation", "Piano improvisation or a good shake.", "music.note")
    ]

    var body: some View {
        ZStack {
            BotTheme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                progress
                ScrollView {
                    VStack(spacing: 24) {
                        switch step {
                        case 0: welcomeStep
                        case 1: focusStep
                        case 2: supportsStep
                        case 3: starterStep
                        default: syncStep
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
                bottomBar
            }
        }
        .preferredColorScheme(.light)
    }

    private var progress: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? BotTheme.accent : BotTheme.line)
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private var welcomeStep: some View {
        VStack(spacing: 18) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(BotTheme.sage)
                .frame(width: 104, height: 104)
                .background(BotTheme.sageSoft, in: Circle())
                .shadow(color: BotTheme.sage.opacity(0.12), radius: 18, x: 0, y: 9)
            Text("A gentler rhythm starts here.")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
                .multilineTextAlignment(.center)
            Text("Back on Track is a quiet place for sleep, small tasks and stopping when you need to. No streaks. No scores. Nothing to catch up on.")
                .font(.body)
                .foregroundStyle(BotTheme.soft)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                featureRow("Made for busy minds", "Few choices, clear next steps and smallest versions.", "sparkles")
                featureRow("Your pace", "Missed days stay missed. The app never punishes you.", "heart")
                featureRow("Private by default", "Use it on this phone, or choose sync later.", "lock")
            }
            .botCard()
        }
    }

    private var focusStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What tends to pull you in?")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
            Text("Optional. This only personalises the pause card — it is not a diagnosis or a label.")
                .font(.subheadline).foregroundStyle(BotTheme.soft)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(focusOptions, id: \.0) { option in
                    optionCard(option.0, option.1, option.2, selected: focusArea == option.0) {
                        focusArea = option.0
                    }
                }
            }
            if focusArea == "other" {
                TextField("What would you like help pausing?", text: $customFocus)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var supportsStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What would feel supportive?")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
            Text("Pick any. You can change these later.")
                .font(.subheadline).foregroundStyle(BotTheme.soft)
            VStack(spacing: 10) {
                ForEach(supportOptions, id: \.0) { option in
                    supportCard(option)
                }
            }
        }
    }

    private var starterStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How should we begin?")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
            Text("You can add, remove and borrow tasks at any time.")
                .font(.subheadline).foregroundStyle(BotTheme.soft)
            choiceCard(
                "gentle",
                title: "A gentle starter set",
                detail: "A few morning tasks, daily anchors, evening alternatives and shelves. All optional.",
                icon: "leaf"
            )
            choiceCard(
                "empty",
                title: "Start empty",
                detail: "A clean slate. Add only what you choose, when you choose it.",
                icon: "plus.circle"
            )
        }
    }

    private var syncStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Keep it here, or take it with you?")
                .font(BotTheme.titleFont)
                .foregroundStyle(BotTheme.ink)
            Text("Sync is optional. Local-only data stays in this app on this phone.")
                .font(.subheadline).foregroundStyle(BotTheme.soft)
            choiceCard(
                "local",
                title: "Use on this phone only",
                detail: "No account needed. You can connect to sync later from Links.",
                icon: "iphone"
            )
            choiceCard(
                "sync",
                title: "Connect for sync",
                detail: "Sign in or create an account so your rhythm can follow you to another device.",
                icon: "arrow.triangle.2.circlepath"
            )
            Text("Health data is never required and is never written by this app.")
                .font(.caption).foregroundStyle(BotTheme.soft)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if step > 0 {
                Button { step -= 1 } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 52, height: 50)
                        .background(BotTheme.card, in: Capsule())
                        .foregroundStyle(BotTheme.ink)
                }
                .buttonStyle(.plain)
            }
            Button(action: advance) {
                HStack {
                    Text(step == 4 ? "Begin" : "Continue")
                    Image(systemName: step == 4 ? "checkmark" : "arrow.right")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(BotTheme.accentGradient, in: Capsule())
                .foregroundStyle(.white)
                .shadow(color: BotTheme.accent.opacity(0.16), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(step == 1 && focusArea == "other" && customFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(20)
    }

    private func advance() {
        if step < 4 { step += 1; return }
        let label: String
        switch focusArea {
        case "coding": label = "Coding"
        case "gaming": label = "Gaming"
        case "scrolling": label = "Scrolling"
        case "shopping": label = "Shopping"
        case "food": label = "Food"
        case "other": label = customFocus.trimmingCharacters(in: .whitespacesAndNewlines)
        default: label = "a gentle pause"
        }
        let personalization = Personalization(
            onboardingComplete: true,
            focusArea: focusArea,
            focusLabel: label,
            customFocus: customFocus,
            supports: Array(supports).sorted(),
            starterSet: starterSet
        )
        store.completeOnboarding(personalization)
        if syncChoice == "local" { auth.useLocalOnly() }
    }

    @State private var syncChoice = "local"

    private func optionCard(_ id: String, _ title: String, _ icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon).foregroundStyle(selected ? BotTheme.accent : BotTheme.soft)
                    Spacer()
                    if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(BotTheme.accent) }
                }
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(BotTheme.ink)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
            .background(selected ? BotTheme.accentSoft.opacity(0.55) : BotTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(selected ? BotTheme.accent.opacity(0.35) : BotTheme.line.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func supportCard(_ option: (String, String, String, String)) -> some View {
        let selected = supports.contains(option.0)
        return Button { if selected { supports.remove(option.0) } else { supports.insert(option.0) } } label: {
            HStack(spacing: 12) {
                Image(systemName: option.3)
                    .foregroundStyle(selected ? BotTheme.accent : BotTheme.soft)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.1).font(.subheadline.weight(.semibold)).foregroundStyle(BotTheme.ink)
                    Text(option.2).font(.caption).foregroundStyle(BotTheme.soft)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? BotTheme.accent : BotTheme.soft)
            }
            .padding(14)
            .background(selected ? BotTheme.accentSoft.opacity(0.35) : BotTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func choiceCard(_ id: String, title: String, detail: String, icon: String) -> some View {
        let selected = (id == "gentle" || id == "empty") ? starterSet == id : syncChoice == id
        return Button {
            if id == "gentle" || id == "empty" { starterSet = id }
            else { syncChoice = id }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(selected ? BotTheme.accent : BotTheme.soft)
                    .frame(width: 38, height: 38)
                    .background(selected ? BotTheme.accentSoft : BotTheme.field, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline).foregroundStyle(BotTheme.ink)
                    Text(detail).font(.caption).foregroundStyle(BotTheme.soft)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? BotTheme.accent : BotTheme.soft)
            }
            .padding(16)
            .background(selected ? BotTheme.accentSoft.opacity(0.35) : BotTheme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(selected ? BotTheme.accent.opacity(0.28) : BotTheme.line.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func featureRow(_ title: String, _ detail: String, _ icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(BotTheme.sage).frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(BotTheme.ink)
                Text(detail).font(.caption).foregroundStyle(BotTheme.soft)
            }
        }
    }
}
