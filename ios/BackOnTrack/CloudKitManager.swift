import CloudKit
import Foundation

@MainActor
final class CloudKitManager: ObservableObject {
    private let container = CKContainer(identifier: "iCloud.com.danielebuatti.backontrack")
    private var db: CKDatabase { container.privateCloudDatabase }

    @Published var status: String = "Not synced"
    @Published var lastSync: Date?

    func fetchState() async -> AppState? {
        let recordID = CKRecord.ID(recordName: "bot-state")
        do {
            let record = try await db.record(for: recordID)
            if let json = record["stateJSON"] as? String,
               let data = json.data(using: .utf8) {
                let decoded = try JSONDecoder().decode(AppState.self, from: data)
                status = "Pulled"
                lastSync = Date()
                return decoded
            }
        } catch let e as CKError where e.code == .unknownItem {
            // no record yet
            status = "No remote state"
        } catch {
            status = "Pull failed: \(error.localizedDescription)"
        }
        return nil
    }

    func pushState(_ state: AppState) async {
        let recordID = CKRecord.ID(recordName: "bot-state")
        let record: CKRecord
        do {
            record = try await db.record(for: recordID)
        } catch {
            record = CKRecord(recordType: "BotState", recordID: recordID)
        }
        if let data = try? JSONEncoder().encode(state),
           let json = String(data: data, encoding: .utf8) {
            record["stateJSON"] = json
            record["updatedAt"] = state.settings.updatedAt as CKRecordValue
        }
        do {
            _ = try await db.save(record)
            status = "Pushed"
            lastSync = Date()
        } catch {
            status = "Push failed: \(error.localizedDescription)"
        }
    }
}