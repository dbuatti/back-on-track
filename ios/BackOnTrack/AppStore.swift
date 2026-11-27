import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published var state: AppState = AppState()
    @Published var isReady: Bool = false

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
                if !hadLocal || remoteStamp >= localStamp {
                    state = remote
                    persistLocal()
                } else if hasMeaningfulData {
                    await supabase.pushState(state)
                }
            } else if hasMeaningfulData {
                // Never turn a failed pull or an empty fresh install into a push.
                await supabase.pushState(state)
            }
        }
        if !UserDefaults.standard.bool(forKey: "bot.defaultsSeededV1") {
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
        isReady = true
    }

    func save() {
        state.settings.updatedAt = Date().timeIntervalSince1970 * 1000
        persistLocal()
        Task { await supabase.pushState(state) }
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