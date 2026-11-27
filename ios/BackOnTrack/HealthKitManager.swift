import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    @Published var steps: Int = 0
    @Published var walkingKm: Double = 0
    @Published var mindfulMinutes: Int = 0
    @Published var isAuthorized = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let store = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)
    private let walkType = HKQuantityType(.distanceWalkingRunning)
    private let mindfulType = HKQuantityType(.mindfulMinutes)

    private init() {
        isAuthorized = [stepType, walkType, mindfulType].contains {
            store.authorizationStatus(for: $0) == .sharingAuthorized
        }
    }

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async {
        guard isAvailable else {
            errorMessage = "Health data isn't available on this iPhone."
            return
        }
        do {
            try await store.requestAuthorization(toShare: [], read: [stepType, walkType, mindfulType])
            isAuthorized = [stepType, walkType, mindfulType].contains {
                store.authorizationStatus(for: $0) == .sharingAuthorized
            }
            if isAuthorized { await loadToday() }
            else { errorMessage = "Health access is off. You can enable it in Settings → Privacy & Security → Health." }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadToday() async {
        guard isAvailable else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let start = Calendar.current.startOfDay(for: Date())
        let end = Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        async let stepValue = sum(for: stepType, unit: .count(), predicate: predicate)
        async let walkValue = sum(for: walkType, unit: .meter(), predicate: predicate)
        async let mindfulValue = sum(for: mindfulType, unit: .minute(), predicate: predicate)

        do {
            let (s, w, m) = try await (stepValue, walkValue, mindfulValue)
            steps = Int(s.rounded())
            walkingKm = w / 1000
            mindfulMinutes = Int(m.rounded())
            isAuthorized = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sum(for type: HKQuantityType, unit: HKUnit, predicate: NSPredicate) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }
}