import Foundation

struct DayRecord: Codable, Identifiable, Hashable {
    var id: String { date }
    var date: String // YYYY-MM-DD
    var checks: [String: Bool]
    var intention: String
    var readingMinutes: Int?
    var bedTime: String?
    var wakeTime: String?
    var mood: String?
    var note: String
    var codingNextStep: String?

    static func empty(_ date: String) -> DayRecord {
        DayRecord(date: date, checks: [:], intention: "", readingMinutes: nil, bedTime: nil, wakeTime: nil, mood: nil, note: "", codingNextStep: nil)
    }
}

struct ListItem: Codable, Identifiable, Hashable {
    var id: String
    var text: String
    var note: String?
    var small: String?
    var url: String?
}

struct ShelfItem: Codable, Identifiable, Hashable {
    var id: String
    var text: String
    var note: String?
    var small: String?
}

struct Shelf: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var note: String
    var items: [ShelfItem]
    var tone: String
}

struct Loan: Codable, Identifiable, Hashable {
    var id: String
    var itemId: String
    var shelfId: String
    var list: String // "morning" | "anchors"
}

struct Program30State: Codable, Hashable {
    var loaded: Bool = false
    var step: Int = 0
    var startedAt: String = ""
    var lastDoneAt: String = ""
    var done: [String: String] = [:] // step id -> date
    var reflection: String = ""
    var notes: [String: String] = [:]
}

struct AppSettings: Codable, Hashable {
    var targetBed: String = "22:30"
    var intentionIndex: Int = 0
    var intentionDay: String = ""
    var myLinks: [ListItem] = []
    var shelves: [Shelf] = []
    var loans: [Loan] = []
    var walkStartMinutes: Int = 10
    var program30: Program30State = Program30State()
    var updatedAt: Double = 0
    var doneForToday: String = ""
    var lists: Lists = Lists()

    struct Lists: Codable, Hashable {
        var morning: [ListItem] = []
        var anchors: [ListItem] = []
        var instead: [ListItem] = []
    }
}

struct AppState: Codable {
    var settings: AppSettings = AppSettings()
    var days: [String: DayRecord] = [:]
}