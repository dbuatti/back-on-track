import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published var state: AppState = AppState()
    @Published var isReady: Bool = false
    @Published var hasBootstrapped: Bool = false

    let supabase = SupabaseManager.shared
    private let localKey = "bot.state"

    func bootstrap(auth: AuthManager) async {
        let hadLocal = UserDefaults.standard.data(forKey: localKey) != nil
        loadLocal()
        if auth.isSignedIn {
            if let remote = await supabase.fetchState() {
                UserDefaults.standard.set(true, forKey: "bot.syncedOnce")
                let localStamp = state.settings.updatedAt
                let remoteStamp = remote.settings.updatedAt
                // First launch on a device must take the cloud copy even when
                // both timestamps are zero (older web exports can be zero).
                if !hadLocal {
                    state = remote
                    persistLocal()
                } else {
                    // Always union, even when the remote is newer: a mark made
                    // offline just before opening must survive the pull.
                    state = StateMerge.merge(local: state, remote: remote)
                    persistLocal()
                    if hasMeaningfulData && localStamp > remoteStamp {
                        await supabase.pushState(state)
                    }
                }
            } else if hasMeaningfulData {
                // Never turn a failed pull or an empty fresh install into a push.
                await supabase.pushState(state)
            }
        }
        // Existing installs predate onboarding. Keep their current content and
        // mark them complete instead of interrupting an established rhythm.
        if state.settings.personalization == nil && (hadLocal || auth.isSignedIn) {
            state.settings.personalization = Personalization(
                onboardingComplete: true,
                focusArea: "coding",
                focusLabel: "Coding",
                customFocus: "",
                supports: ["pause", "smallSteps", "sleep"],
                starterSet: "gentle"
            )
            persistLocal()
        }
        if hasCompletedOnboarding && !UserDefaults.standard.bool(forKey: "bot.defaultsSeededV1") {
            let before = try? JSONEncoder().encode(state)
            SeedData.apply(to: &state)
            let after = try? JSONEncoder().encode(state)
            UserDefaults.standard.set(true, forKey: "bot.defaultsSeededV1")
            if before != after {
                state.settings.updatedAt = Date().timeIntervalSince1970 * 1000
                persistLocal()
                if auth.isSignedIn { await supabase.pushState(state) }
            }
        }
        if !UserDefaults.standard.bool(forKey: "bot.selfRegSeededV1") {
            if !state.settings.shelves.contains(where: { $0.id == "sh_selfreg" }) {
                state.settings.shelves.append(SeedData.selfRegulationShelf())
                state.settings.updatedAt = Date().timeIntervalSince1970 * 1000
                persistLocal()
                if auth.isSignedIn { await supabase.pushState(state) }
            }
            UserDefaults.standard.set(true, forKey: "bot.selfRegSeededV1")
        }
        isReady = true
        hasBootstrapped = true
    }

    var hasCompletedOnboarding: Bool {
        state.settings.personalization?.onboardingComplete == true ||
        UserDefaults.standard.bool(forKey: "bot.onboardingComplete")
    }

    func completeOnboarding(_ personalization: Personalization) {
        state.settings.personalization = personalization
        UserDefaults.standard.set(true, forKey: "bot.onboardingComplete")
        if personalization.starterSet == "gentle" && !UserDefaults.standard.bool(forKey: "bot.defaultsSeededV1") {
            SeedData.apply(to: &state)
            UserDefaults.standard.set(true, forKey: "bot.defaultsSeededV1")
        }
        save()
        isReady = true
    }

    func save() {
        state.settings.updatedAt = Date().timeIntervalSince1970 * 1000
        persistLocal()
        Task { await supabase.pushState(state) }
    }

    func exportData() -> URL {
        let data = (try? JSONEncoder().encode(state)) ?? Data()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("back-on-track-\(todayKey()).json")
        try? data.write(to: url, options: .atomic)
        return url
    }

    func importData(from url: URL) async -> Bool {
        guard url.startAccessingSecurityScopedResource() else { return false }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            let data = try Data(contentsOf: url)
            let incoming = try JSONDecoder().decode(AppState.self, from: data)
            mergeImported(incoming)
            return true
        } catch {
            return false
        }
    }

    private func mergeImported(_ incoming: AppState) {
        let localStamp = state.settings.updatedAt
        let incomingStamp = incoming.settings.updatedAt
        if incomingStamp > localStamp {
            state = incoming
            save()
            return
        }
        // Older or equally timed backup: fill gaps, never erase local work.
        for (key, day) in incoming.days where state.days[key] == nil {
            state.days[key] = day
        }
        appendMissing(incoming.settings.lists.morning, to: &state.settings.lists.morning)
        appendMissing(incoming.settings.lists.anchors, to: &state.settings.lists.anchors)
        appendMissing(incoming.settings.lists.instead, to: &state.settings.lists.instead)
        appendMissing(incoming.settings.shelves, to: &state.settings.shelves)
        appendMissing(incoming.settings.loans, to: &state.settings.loans)
        appendMissing(incoming.settings.myLinks, to: &state.settings.myLinks)
        save()
    }

    private func appendMissing<T: Identifiable>(_ incoming: [T], to local: inout [T]) where T.ID: Hashable {
        let ids = Set(local.map(\.id))
        for item in incoming where !ids.contains(item.id) {
            local.append(item)
        }
    }

    func creditCozy() {
        if state.settings.cozyTimer == nil { state.settings.cozyTimer = CozyTimerState() }
        guard var ct = state.settings.cozyTimer else { return }
        defer { state.settings.cozyTimer = ct }
        let today = todayKey()
        if ct.lastCreditedDay.isEmpty {
            ct.lastCreditedDay = today
            persistLocal()
            return
        }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let start = f.date(from: ct.lastCreditedDay), let end = f.date(from: today) else { return }
        let days = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: start), to: Calendar.current.startOfDay(for: end)).day ?? 0)
        if days > 0 {
            let added = ct.dailyMinutes * Double(days)
            ct.bankedMinutes += added
            if ct.active { ct.remainingAtStart += added }
            else {
                ct.remaining = ct.bankedMinutes
                ct.remainingAtStart = ct.remaining
            }
            ct.lastCreditedDay = today
            persistLocal()
        }
    }

    func cozyRemaining(now: Date = Date()) -> Double {
        guard let ct = state.settings.cozyTimer else { return 30 }
        if !ct.active { return max(0, ct.remaining) }
        let elapsed = now.timeIntervalSince1970 - ct.startedAt
        return max(0, ct.remainingAtStart - elapsed / 60)
    }

    func startCozy(now: Date = Date()) {
        creditCozy()
        guard var ct = state.settings.cozyTimer, ct.bankedMinutes > 0 else { return }
        if ct.remaining <= 0 { ct.remaining = ct.bankedMinutes }
        ct.remainingAtStart = ct.remaining
        ct.startedAt = now.timeIntervalSince1970
        ct.active = true
        state.settings.cozyTimer = ct
        save()
    }

    func stopCozy(finished: Bool, now: Date = Date()) {
        guard var ct = state.settings.cozyTimer else { return }
        let left = cozyRemaining(now: now)
        if finished {
            ct.bankedMinutes = 0
            ct.remaining = 0
            ct.remainingAtStart = 0
        } else {
            ct.bankedMinutes = left
            ct.remaining = left
            ct.remainingAtStart = left
        }
        ct.active = false
        ct.startedAt = 0
        state.settings.cozyTimer = ct
        save()
    }

    func setCozyDaily(_ minutes: Double) {
        guard var ct = state.settings.cozyTimer else { return }
        ct.dailyMinutes = minutes
        if !ct.active {
            ct.remaining = ct.bankedMinutes
            ct.remainingAtStart = ct.remaining
        }
        state.settings.cozyTimer = ct
        save()
    }

    func removeCozyPossibility(_ text: String) {
        guard var ct = state.settings.cozyTimer else { return }
        ct.custom.removeAll(where: { $0 == text })
        state.settings.cozyTimer = ct
        save()
    }

    func addCozyPossibility(_ text: String) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        guard var ct = state.settings.cozyTimer else { return }
        if !ct.custom.contains(value) { ct.custom.append(value) }
        state.settings.cozyTimer = ct
        save()
    }

    func setDoneForToday(_ done: Bool) {
        state.settings.doneForToday = done ? todayKey() : ""
        save()
    }

    func logTime(_ kind: String) {
        let today = todayKey()
        if state.days[today] == nil { state.days[today] = DayRecord.empty(today) }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let value = f.string(from: Date())
        if kind == "bed" { state.days[today]?.bedTime = value }
        else { state.days[today]?.wakeTime = value }
        save()
    }

    func setProgramLoaded(_ loaded: Bool) {
        state.settings.program30.loaded = loaded
        save()
    }

    func setProgramPace(_ pace: String) {
        state.settings.program30.pace = pace
        save()
    }

    /// One invitation per day. Marks are kept for sync, but the card hides
    /// until the next day so there is nothing to click through.
    func programDoneToday() -> Bool {
        state.settings.program30.lastDoneAt == todayKey()
    }

    @discardableResult
    func completeProgramStep() -> Program30State? {
        if programDoneToday() { return nil }
        let p = state.settings.program30
        let before = p
        let index = min(max(p.step, 0), Program.steps.count - 1)
        let step = Program.effectiveStep(state: state, index: index)
        let today = todayKey()
        state.settings.program30.done[step.id] = today
        state.settings.program30.lastDoneAt = today
        if state.settings.program30.startedAt.isEmpty { state.settings.program30.startedAt = today }
        if state.settings.program30.step < Program.steps.count - 1 {
            state.settings.program30.step += 1
        }
        save()
        return before
    }

    func undoProgramStep(_ before: Program30State) {
        state.settings.program30 = before
        save()
    }

    func addNickToMorning() {
        let nickURL = "https://functional-neuro-health.mykajabi.com/products/neuro-pro-mastery-program/categories/2154161935/posts/2202064260"
        if state.settings.lists.morning.contains(where: { $0.id == "m_nick" }) { return }

        let shelfIndex: Int
        if let existing = state.settings.shelves.firstIndex(where: { $0.id == "sh_notfeeling" }) {
            shelfIndex = existing
        } else {
            state.settings.shelves.insert(Shelf(id: "sh_notfeeling", name: "Not feeling it", note: "Small ways through", items: [], tone: "clay"), at: 0)
            shelfIndex = 0
        }
        if !state.settings.shelves[shelfIndex].items.contains(where: { $0.id == "g_nick" }) {
            state.settings.shelves[shelfIndex].items.insert(
                ShelfItem(id: "g_nick", text: "Nick Moss daily meditation", note: "a gentle place to begin", small: "Just open the page."),
                at: 0
            )
        }
        state.settings.lists.morning.insert(ListItem(
            id: "m_nick",
            text: "Nick Moss daily meditation",
            note: "Not feeling it",
            small: "Just open the page. No listening needed — that's enough.",
            url: nickURL
        ), at: 0)
        if !state.settings.loans.contains(where: { $0.id == "ln_g_nick_morning" }) {
            state.settings.loans.insert(Loan(id: "ln_g_nick_morning", itemId: "g_nick", shelfId: "sh_notfeeling", list: "morning"), at: 0)
        }
        save()
    }

    func addTask(_ text: String, small: String, to list: String) {
        let title = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let id = "custom_\(UUID().uuidString.prefix(8))"
        let item = ListItem(id: id, text: title, note: nil, small: small.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Just the smallest part." : small, url: nil)
        if list == "morning" { state.settings.lists.morning.append(item) }
        else { state.settings.lists.anchors.append(item) }
        save()
    }

    func removeTask(_ id: String, from list: String) {
        let source: [ListItem]
        if list == "morning" { source = state.settings.lists.morning }
        else { source = state.settings.lists.anchors }
        guard let item = source.first(where: { $0.id == id }) else { return }

        var keepIndex = state.settings.shelves.firstIndex(where: { $0.id == "sh_keepclose" })
        if keepIndex == nil {
            state.settings.shelves.append(Shelf(id: "sh_keepclose", name: "Keep close", note: "Good for you, just not in the daily rhythm.", items: [], tone: "slate"))
            keepIndex = state.settings.shelves.count - 1
        }
        state.settings.shelves[keepIndex!].items.append(ShelfItem(id: item.id, text: item.text, note: item.note, small: item.small))
        if list == "morning" { state.settings.lists.morning.removeAll(where: { $0.id == id }) }
        else { state.settings.lists.anchors.removeAll(where: { $0.id == id }) }
        save()
    }

    func borrow(shelfId: String, itemId: String, into list: String) {
        guard let shelfIndex = state.settings.shelves.firstIndex(where: { $0.id == shelfId }),
              let item = state.settings.shelves[shelfIndex].items.first(where: { $0.id == itemId }) else { return }
        let loanId = "ln_\(itemId)_\(list)"
        if state.settings.loans.contains(where: { $0.id == loanId }) { return }
        let row = ListItem(id: loanId, text: item.text, note: item.note, small: item.small)
        if list == "morning" { state.settings.lists.morning.append(row) }
        else { state.settings.lists.anchors.append(row) }
        state.settings.loans.append(Loan(id: loanId, itemId: itemId, shelfId: shelfId, list: list))
        save()
    }

    func syncNow() async {
        guard supabase.isSignedIn else { return }
        if let remote = await supabase.fetchState() {
            let localStamp = state.settings.updatedAt
            let remoteStamp = remote.settings.updatedAt
            if !UserDefaults.standard.bool(forKey: "bot.syncedOnce") || remoteStamp >= localStamp {
                state = remote
                persistLocal()
            } else if localStamp > remoteStamp && hasMeaningfulData {
                await supabase.pushState(state)
            }
            UserDefaults.standard.set(true, forKey: "bot.syncedOnce")
        } else if hasMeaningfulData {
            await supabase.pushState(state)
        }
    }

    private var hasMeaningfulData: Bool {
        !state.days.isEmpty ||
        !state.settings.lists.morning.isEmpty ||
        !state.settings.lists.anchors.isEmpty ||
        !state.settings.lists.instead.isEmpty ||
        !state.settings.shelves.isEmpty ||
        !state.settings.myLinks.isEmpty ||
        !state.settings.program30.done.isEmpty
    }

    private func persistLocal() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: localKey)
        }
    }

    private func loadLocal() {
        if let data = UserDefaults.standard.data(forKey: localKey),
           let decoded = try? JSONDecoder().decode(AppState.self, from: data) {
            state = decoded
        }
    }
}