import Foundation

/// Safe, id-based union merge. Neither side's rows are silently dropped: a
/// device that added a task, mark or link offline keeps it after a pull.
enum StateMerge {
    static func merge(local: AppState, remote: AppState) -> AppState {
        var result = remote
        let a = local.settings
        let b = remote.settings
        let incomingWins = (b.updatedAt) > (a.updatedAt)

        // Days are keyed by date. Merge checks by task id; scalars prefer the
        // newer side but never overwrite a value with an empty one.
        for (key, day) in local.days {
            if var existing = result.days[key] {
                existing.checks = mergingChecks(a: existing.checks, b: day.checks)
                existing.intention = preferString(existing.intention, day.intention, incomingWins: incomingWins)
                existing.note = preferString(existing.note, day.note, incomingWins: incomingWins)
                existing.mood = prefer(existing.mood, day.mood, incomingWins: incomingWins)
                existing.bedTime = prefer(existing.bedTime, day.bedTime, incomingWins: incomingWins)
                existing.wakeTime = prefer(existing.wakeTime, day.wakeTime, incomingWins: incomingWins)
                existing.readingMinutes = existing.readingMinutes ?? day.readingMinutes
                existing.codingNextStep = prefer(existing.codingNextStep, day.codingNextStep, incomingWins: incomingWins)
                result.days[key] = existing
            } else {
                result.days[key] = day
            }
        }

        result.settings.lists.morning = union(a.lists.morning, b.lists.morning)
        result.settings.lists.anchors = union(a.lists.anchors, b.lists.anchors)
        result.settings.lists.instead = union(a.lists.instead, b.lists.instead)
        result.settings.shelves = unionShelves(a.shelves, b.shelves)
        result.settings.loans = union(a.loans, b.loans)
        result.settings.myLinks = union(a.myLinks, b.myLinks)

        // Program marks are always a union; scalar fields prefer the newer
        // side, but an empty reflection never erases one already written.
        var program = b.program30
        program.done = program.done.merging(a.program30.done) { _, newer in newer }
        program.notes = program.notes.merging(a.program30.notes) { _, newer in newer }
        if program.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            program.reflection = a.program30.reflection
        }
        program.step = max(a.program30.step, b.program30.step)
        result.settings.program30 = program

        result.settings.cozyTimer = mergeCozy(a.cozyTimer, b.cozyTimer, incomingWins: incomingWins)
        result.settings.labItems = union(a.labItems ?? [], b.labItems ?? [])
        result.settings.updatedAt = max(a.updatedAt, b.updatedAt)
        return result
    }

    private static func prefer(_ a: String?, _ b: String?, incomingWins: Bool) -> String? {
        let first = incomingWins ? b : a
        let second = incomingWins ? a : b
        if let value = first, !value.isEmpty { return value }
        if let value = second, !value.isEmpty { return value }
        return first ?? second
    }

    private static func preferString(_ a: String, _ b: String, incomingWins: Bool) -> String {
        let first = incomingWins ? b : a
        let second = incomingWins ? a : b
        return first.isEmpty ? second : first
    }

    private static func mergingChecks(a: [String: Bool], b: [String: Bool]) -> [String: Bool] {
        var out = a
        for (key, value) in b where value { out[key] = true }
        return out
    }

    private static func union<T: Identifiable>(_ a: [T], _ b: [T]) -> [T] where T.ID: Hashable {
        var seen = Set<T.ID>()
        var out: [T] = []
        for item in b + a where !seen.contains(item.id) {
            seen.insert(item.id)
            out.append(item)
        }
        return out
    }

    private static func unionShelves(_ a: [Shelf], _ b: [Shelf]) -> [Shelf] {
        var out = b
        for shelf in a {
            if let idx = out.firstIndex(where: { $0.id == shelf.id }) {
                var items = out[idx].items
                let ids = Set(items.map(\.id))
                for item in shelf.items where !ids.contains(item.id) { items.append(item) }
                out[idx].items = items
            } else {
                out.append(shelf)
            }
        }
        return out
    }

    private static func mergeCozy(_ a: CozyTimerState?, _ b: CozyTimerState?, incomingWins: Bool) -> CozyTimerState? {
        guard var result = b ?? a else { return nil }
        if let a {
            result.dailyMinutes = incomingWins ? result.dailyMinutes : a.dailyMinutes
            result.bankedMinutes = max(a.bankedMinutes, result.bankedMinutes)
            result.custom = Array(Set(a.custom + result.custom))
        }
        return result
    }
}
