import XCTest
@testable import BackOnTrack

final class MergeTests: XCTestCase {
    func testOfflineMarkSurvivesNewerRemotePull() {
        var local = AppState()
        local.settings.updatedAt = 100
        local.settings.lists.anchors.append(ListItem(id: "a_walk", text: "Walk", note: nil, small: nil, url: nil))
        local.days["2026-11-28"] = DayRecord.empty("2026-11-28")
        local.days["2026-11-28"]?.checks["a_walk"] = true

        var remote = AppState()
        remote.settings.updatedAt = 200
        remote.settings.lists.anchors.append(ListItem(id: "a_read", text: "Reading", note: nil, small: nil, url: nil))

        let merged = StateMerge.merge(local: local, remote: remote)
        XCTAssertTrue(merged.days["2026-11-28"]?.checks["a_walk"] == true)
        XCTAssertTrue(merged.settings.lists.anchors.contains(where: { $0.id == "a_walk" }))
        XCTAssertTrue(merged.settings.lists.anchors.contains(where: { $0.id == "a_read" }))
        XCTAssertEqual(merged.settings.updatedAt, 200)
    }

    func testEmptyReflectionDoesNotEraseWrittenOne() {
        var local = AppState()
        local.settings.program30.reflection = "I noticed the walk helped."
        var remote = AppState()
        remote.settings.program30.reflection = ""
        let merged = StateMerge.merge(local: local, remote: remote)
        XCTAssertEqual(merged.settings.program30.reflection, "I noticed the walk helped.")
    }

    func testProgramMarksAreUnion() {
        var local = AppState()
        local.settings.program30.done["p1_01"] = "2026-11-27"
        var remote = AppState()
        remote.settings.program30.done["p1_02"] = "2026-11-28"
        let merged = StateMerge.merge(local: local, remote: remote)
        XCTAssertEqual(merged.settings.program30.done.count, 2)
    }

    func testShelfItemsMergeById() {
        var local = AppState()
        local.settings.shelves = [Shelf(id: "sh_x", name: "X", note: "", items: [
            ShelfItem(id: "one", text: "One", note: nil, small: nil)
        ], tone: "clay")]
        var remote = AppState()
        remote.settings.shelves = [Shelf(id: "sh_x", name: "X", note: "", items: [
            ShelfItem(id: "two", text: "Two", note: nil, small: nil)
        ], tone: "clay")]
        let merged = StateMerge.merge(local: local, remote: remote)
        XCTAssertEqual(merged.settings.shelves.first?.items.count, 2)
    }
}
