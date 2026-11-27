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

    func testProgramStateWithoutPaceDecodes() throws {
        let json = """
        {"loaded":false,"step":0,"startedAt":"","lastDoneAt":"","done":{},"reflection":""}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Program30State.self, from: json)
        XCTAssertNil(decoded.pace)
    }
}
