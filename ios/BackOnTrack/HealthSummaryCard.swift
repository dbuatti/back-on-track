import SwiftUI

enum HealthKitConfig {
    // Flip to true and attach BackOnTrack-HealthKit.entitlements once the paid
    // Apple Developer capability is enabled.
    static let enabled = false
}

struct HealthSummaryCard: View {
    @StateObject private var health = HealthKitManager.shared
    @State private var showingDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                BotSectionHeader(title: "Movement & mindfulness", systemImage: "heart.text.square", tint: BotTheme.sage)
                Spacer()
                if HealthKitConfig.enabled && health.isAuthorized {
                    Button { Task { await health.loadToday() } } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 0) {
                stat(value: health.isAuthorized ? "\(health.steps)" : "—", label: "Steps", icon: "figure.walk")
                stat(value: health.isAuthorized ? String(format: "%.1f", health.walkingKm) : "—", label: "Walk km", icon: "route")
                stat(value: health.isAuthorized ? "\(health.mindfulMinutes)" : "—", label: "Mindful min", icon: "brain.head.profile")
            }

            if !HealthKitConfig.enabled {
                Text("HealthKit sync is ready. It turns on when the paid Apple developer capability is added.")
                    .font(.caption).foregroundStyle(BotTheme.soft)
            } else if !health.isAuthorized {
                Button("Connect Health") { Task { await health.requestAuthorization() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(BotTheme.sage, in: Capsule())
                    .buttonStyle(.plain)
            } else if let error = health.errorMessage {
                Text(error).font(.caption).foregroundStyle(BotTheme.accent)
            }
        }
        .botCard()
        .task {
            if HealthKitConfig.enabled && health.isAuthorized {
                await health.loadToday()
            }
        }
    }

    private func stat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(BotTheme.sage)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(BotTheme.ink)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(BotTheme.soft)
        }
        .frame(maxWidth: .infinity)
    }
}