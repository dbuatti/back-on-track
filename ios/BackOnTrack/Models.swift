import Foundation

struct DayRecord: Codable, Identifiable, Hashable {
    var id: String { date }
    var date: String
    var checks: [String: Bool]
    var intention: String
    var readingMinutes: Int?
    var bedTime: String?
    var wakeTime: String?
    var mood: String?
    var note: String
    var codingNextStep: String?

    init(date: String, checks: [String: Bool], intention: String, readingMinutes: Int?, bedTime: String?, wakeTime: String?, mood: String?, note: String, codingNextStep: String?) {
        self.date = date
        self.checks = checks
        self.intention = intention
        self.readingMinutes = readingMinutes
        self.bedTime = bedTime
        self.wakeTime = wakeTime
        self.mood = mood
        self.note = note
        self.codingNextStep = codingNextStep
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date = try c.decodeIfPresent(String.self, forKey: .date) ?? ""
        checks = try c.decodeIfPresent([String: Bool].self, forKey: .checks) ?? [:]
        intention = try c.decodeIfPresent(String.self, forKey: .intention) ?? ""
        readingMinutes = try c.decodeIfPresent(Int.self, forKey: .readingMinutes)
        bedTime = try c.decodeIfPresent(String.self, forKey: .bedTime)
        wakeTime = try c.decodeIfPresent(String.self, forKey: .wakeTime)
        mood = try c.decodeIfPresent(String.self, forKey: .mood)
        note = try c.decodeIfPresent(String.self, forKey: .note) ?? ""
        codingNextStep = try c.decodeIfPresent(String.self, forKey: .codingNextStep)
    }

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
    var list: String
}

struct Program30State: Codable, Hashable {
    var loaded: Bool
    var step: Int
    var startedAt: String
    var lastDoneAt: String
    var done: [String: String]
    var reflection: String
    var notes: [String: String]
    var pace: String?

    init() {
        loaded = false
        step = 0
        startedAt = ""
        lastDoneAt = ""
        done = [:]
        reflection = ""
        notes = [:]
        pace = nil
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        loaded = try c.decodeIfPresent(Bool.self, forKey: .loaded) ?? false
        step = try c.decodeIfPresent(Int.self, forKey: .step) ?? 0
        startedAt = try c.decodeIfPresent(String.self, forKey: .startedAt) ?? ""
        lastDoneAt = try c.decodeIfPresent(String.self, forKey: .lastDoneAt) ?? ""
        done = try c.decodeIfPresent([String: String].self, forKey: .done) ?? [:]
        reflection = try c.decodeIfPresent(String.self, forKey: .reflection) ?? ""
        notes = try c.decodeIfPresent([String: String].self, forKey: .notes) ?? [:]
        pace = try c.decodeIfPresent(String.self, forKey: .pace)
    }
}

struct CozyTimerState: Codable, Hashable {
    var dailyMinutes: Double = 30
    var bankedMinutes: Double = 30
    var active: Bool = false
    var remaining: Double = 30
    var remainingAtStart: Double = 30
    var startedAt: Double = 0
    var lastCreditedDay: String = ""
    var custom: [String] = []

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        dailyMinutes = try c.decodeIfPresent(Double.self, forKey: .dailyMinutes) ?? 30
        bankedMinutes = try c.decodeIfPresent(Double.self, forKey: .bankedMinutes) ?? 30
        active = try c.decodeIfPresent(Bool.self, forKey: .active) ?? false
        remaining = try c.decodeIfPresent(Double.self, forKey: .remaining) ?? bankedMinutes
        remainingAtStart = try c.decodeIfPresent(Double.self, forKey: .remainingAtStart) ?? remaining
        startedAt = try c.decodeIfPresent(Double.self, forKey: .startedAt) ?? 0
        lastCreditedDay = try c.decodeIfPresent(String.self, forKey: .lastCreditedDay) ?? ""
        custom = try c.decodeIfPresent([String].self, forKey: .custom) ?? []
    }
}

struct Personalization: Codable, Hashable {
    var onboardingComplete: Bool
    var focusArea: String
    var focusLabel: String
    var customFocus: String
    var supports: [String]
    var starterSet: String

    init(
        onboardingComplete: Bool = false,
        focusArea: String = "none",
        focusLabel: String = "a gentle pause",
        customFocus: String = "",
        supports: [String] = [],
        starterSet: String = "gentle"
    ) {
        self.onboardingComplete = onboardingComplete
        self.focusArea = focusArea
        self.focusLabel = focusLabel
        self.customFocus = customFocus
        self.supports = supports
        self.starterSet = starterSet
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        onboardingComplete = try c.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        focusArea = try c.decodeIfPresent(String.self, forKey: .focusArea) ?? "none"
        focusLabel = try c.decodeIfPresent(String.self, forKey: .focusLabel) ?? "a gentle pause"
        customFocus = try c.decodeIfPresent(String.self, forKey: .customFocus) ?? ""
        supports = try c.decodeIfPresent([String].self, forKey: .supports) ?? []
        starterSet = try c.decodeIfPresent(String.self, forKey: .starterSet) ?? "gentle"
    }
}

struct AppSettings: Codable, Hashable {
    var targetBed: String
    var intentionIndex: Int
    var intentionDay: String
    var myLinks: [ListItem]
    var shelves: [Shelf]
    var loans: [Loan]
    var walkStartMinutes: Int
    var program30: Program30State
    var personalization: Personalization?
    var cozyTimer: CozyTimerState?
    var updatedAt: Double
    var doneForToday: String
    var lists: Lists

    struct Lists: Codable, Hashable {
        var morning: [ListItem]
        var anchors: [ListItem]
        var instead: [ListItem]

        init() {
            morning = []
            anchors = []
            instead = []
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            morning = try c.decodeIfPresent([ListItem].self, forKey: .morning) ?? []
            anchors = try c.decodeIfPresent([ListItem].self, forKey: .anchors) ?? []
            instead = try c.decodeIfPresent([ListItem].self, forKey: .instead) ?? []
        }
    }

    init() {
        targetBed = "22:30"
        intentionIndex = 0
        intentionDay = ""
        myLinks = []
        shelves = []
        loans = []
        walkStartMinutes = 10
        program30 = Program30State()
        personalization = nil
        cozyTimer = CozyTimerState()
        updatedAt = 0
        doneForToday = ""
        lists = Lists()
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        targetBed = try c.decodeIfPresent(String.self, forKey: .targetBed) ?? "22:30"
        intentionIndex = try c.decodeIfPresent(Int.self, forKey: .intentionIndex) ?? 0
        intentionDay = try c.decodeIfPresent(String.self, forKey: .intentionDay) ?? ""
        myLinks = try c.decodeIfPresent([ListItem].self, forKey: .myLinks) ?? []
        shelves = try c.decodeIfPresent([Shelf].self, forKey: .shelves) ?? []
        loans = try c.decodeIfPresent([Loan].self, forKey: .loans) ?? []
        walkStartMinutes = try c.decodeIfPresent(Int.self, forKey: .walkStartMinutes) ?? 10
        program30 = try c.decodeIfPresent(Program30State.self, forKey: .program30) ?? Program30State()
        personalization = try c.decodeIfPresent(Personalization.self, forKey: .personalization)
        cozyTimer = try c.decodeIfPresent(CozyTimerState.self, forKey: .cozyTimer)
        updatedAt = try c.decodeIfPresent(Double.self, forKey: .updatedAt) ?? 0
        doneForToday = try c.decodeIfPresent(String.self, forKey: .doneForToday) ?? ""
        lists = try c.decodeIfPresent(Lists.self, forKey: .lists) ?? Lists()
    }
}

struct AppState: Codable {
    var settings: AppSettings
    var days: [String: DayRecord]

    init() {
        settings = AppSettings()
        days = [:]
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        settings = try c.decodeIfPresent(AppSettings.self, forKey: .settings) ?? AppSettings()
        days = try c.decodeIfPresent([String: DayRecord].self, forKey: .days) ?? [:]
    }
}
