import XCTest
@testable import BackOnTrack

final class ModelTests: XCTestCase {
    func testEmptyDayRoundTrip() throws {
        let day = DayRecord.empty("2026-11-27")
        let data = try JSONEncoder().encode(day)
        let decoded = try JSONDecoder().decode(DayRecord.self, from: data)
        XCTAssertEqual(decoded.date, day.date)
        XCTAssertNil(decoded.codingNextStep)
    }

    func testOldDayWithoutCodingFieldDecodes() throws {
        let json = """
        {"date":"2026-11-27","checks":{},"intention":"","readingMinutes":null,"bedTime":null,"wakeTime":null,"mood":null,"note":""}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DayRecord.self, from: json)
        XCTAssertNil(decoded.codingNextStep)
    }

    func testAppStateWithoutPersonalizationDecodes() throws {
        let json = """
        {"settings":{"lists":{"morning":[],"anchors":[],"instead":[]},"targetBed":"22:30"},"days":{}}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AppState.self, from: json)
        XCTAssertNil(decoded.settings.personalization)
        XCTAssertEqual(decoded.settings.targetBed, "22:30")
    }

    func testCozyTimerDefaultsWhenMissingFields() throws {
        let json = """
        {"dailyMinutes":30,"bankedMinutes":75,"active":false}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(CozyTimerState.self, from: json)
        XCTAssertEqual(decoded.dailyMinutes, 30)
        XCTAssertEqual(decoded.bankedMinutes, 75)
        XCTAssertEqual(decoded.remaining, 75)
        XCTAssertTrue(decoded.custom.isEmpty)
    }

    func testProgramStateWithoutPaceDecodes() throws {
        let json = """
        {"loaded":false,"step":0,"startedAt":"","lastDoneAt":"","done":{},"reflection":""}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Program30State.self, from: json)
        XCTAssertNil(decoded.pace)
    }
}
