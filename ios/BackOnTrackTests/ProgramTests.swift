import XCTest
@testable import BackOnTrack

final class ProgramTests: XCTestCase {
    func testProgramHasSixtyUniqueSteps() {
        XCTAssertEqual(Program.steps.count, 60)
        XCTAssertEqual(Set(Program.steps.map(\.id)).count, 60)
    }

    func testPhasesCoverAllSteps() {
        XCTAssertEqual(Program.phases.count, 6)
        for step in Program.steps {
            XCTAssertTrue((0..<Program.phases.count).contains(step.phase))
        }
    }

    func testFocusSubstitution() {
        var state = AppState()
        state.settings.personalization = Personalization(
            onboardingComplete: true,
            focusArea: "coding",
            focusLabel: "Coding",
            supports: ["pause"],
            starterSet: "gentle"
        )
        let focusStep = Program.steps.first(where: { $0.invitation.contains("{focus}") })!
        let index = Program.steps.firstIndex(where: { $0.id == focusStep.id })!
        let effective = Program.effectiveStep(state: state, index: index)
        XCTAssertTrue(effective.invitation.contains("Coding"))
        XCTAssertFalse(effective.invitation.contains("{focus}"))
    }

    func testGapCreatesReentryWithoutLosingPlace() {
        var state = AppState()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        state.settings.program30.lastDoneAt = formatter.string(from: Date().addingTimeInterval(-5 * 86400))
        let base = Program.steps[10]
        let effective = Program.effectiveStep(state: state, index: 10)
        XCTAssertEqual(effective.id, "return_" + base.id)
        XCTAssertTrue(effective.invitation.contains("Nothing to catch up on"))
        XCTAssertEqual(effective.phase, base.phase)
    }

    func testMinimalPaceUsesSmallerVersion() {
        var state = AppState()
        state.settings.program30.pace = "minimal"
        let index = 2
        let effective = Program.effectiveStep(state: state, index: index)
        XCTAssertEqual(effective.invitation, Program.steps[index].smaller)
    }

    func testLowMoodUsesSmallerVersion() {
        var state = AppState()
        let today = todayKey()
        state.days[today] = DayRecord.empty(today)
        state.days[today]?.mood = "low"
        let index = 4
        let effective = Program.effectiveStep(state: state, index: index)
        XCTAssertEqual(effective.invitation, Program.steps[index].smaller)
        XCTAssertTrue(effective.optional?.contains("stop here") == true)
    }

    func testDaysSinceHandlesEmptyAndInvalid() {
        XCTAssertEqual(Program.daysSince(""), 0)
        XCTAssertEqual(Program.daysSince("not-a-date"), 0)
    }
}
