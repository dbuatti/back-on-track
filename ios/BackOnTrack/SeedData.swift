import Foundation

enum SeedData {
    static let nickURL = "https://functional-neuro-health.mykajabi.com/products/neuro-pro-mastery-program/categories/2154161935/posts/2202064260"

    static func apply(to state: inout AppState) {
        let morningDefaults = [
            ListItem(id: "m_breakfast", text: "Breakfast outside, quiet", note: nil, small: "Open the door and step outside for a moment.", url: nil),
            ListItem(id: "m_sun", text: "Sun movements + sun salute + om", note: nil, small: "One stretch toward the light.", url: nil),
            ListItem(id: "m_nick", text: "Nick Moss daily meditation", note: "Not feeling it", small: "Just open the page. No listening needed — that's enough.", url: nickURL)
        ]
        appendMissing(morningDefaults, to: &state.settings.lists.morning)

        let anchorDefaults = [
            ListItem(id: "a_walk", text: "Walk", note: nil, small: "To the end of the street and back.", url: nil),
            ListItem(id: "a_read", text: "Reading", note: nil, small: "Read one page.", url: nil),
            ListItem(id: "a_journal", text: "Journal", note: nil, small: "Write one line.", url: nil),
            ListItem(id: "a_offscreen", text: "One off-screen thing (tidy, stretch, piano)", note: nil, small: "Tidy one surface.", url: nil)
        ]
        appendMissing(anchorDefaults, to: &state.settings.lists.anchors)

        let insteadDefaults = [
            ListItem(id: "i_journal", text: "Open the journal and write three lines", note: "gentle", small: "Write one line.", url: nil),
            ListItem(id: "i_read", text: "Read 10 pages of whatever's on the table", note: "wind down", small: "Read one page.", url: nil),
            ListItem(id: "i_walk", text: "Walk around the block, no phone", note: "movement", small: "Step outside and take one slow lap.", url: nil),
            ListItem(id: "i_tidy", text: "Tidy one surface — just one", note: "gentle", small: "Put one thing away.", url: nil),
            ListItem(id: "i_piano", text: "Five minutes of piano, for fun", note: "gentle", small: "Play one phrase, then stop.", url: nil)
        ]
        appendMissing(insteadDefaults, to: &state.settings.lists.instead)

        if state.settings.shelves.isEmpty {
            state.settings.shelves = defaultShelves()
        } else {
            for shelf in defaultShelves() {
                if let index = state.settings.shelves.firstIndex(where: { $0.id == shelf.id }) {
                    appendMissing(shelf.items, to: &state.settings.shelves[index].items)
                } else {
                    state.settings.shelves.append(shelf)
                }
            }
        }

        // Keep the shelf and Home view in agreement: Nick is on the shelf and
        // on loan to Morning, never borrowable a second time.
        if state.settings.lists.morning.contains(where: { $0.id == "m_nick" }) &&
           !state.settings.loans.contains(where: { $0.itemId == "g_nick" }) {
            state.settings.loans.append(Loan(id: "ln_g_nick_morning", itemId: "g_nick", shelfId: "sh_notfeeling", list: "morning"))
        }
    }

    private static func appendMissing<T: Identifiable>(_ defaults: [T], to list: inout [T]) where T.ID: Hashable {
        let existing = Set(list.map(\.id))
        for item in defaults where !existing.contains(item.id) {
            list.append(item)
        }
    }

    static func defaultShelves() -> [Shelf] {
        let notFeeling = [
            ShelfItem(id: "g_sangha", text: "Sangha meditation", note: "Not feeling it", small: "One breath, eyes closed."),
            ShelfItem(id: "g_kriya", text: "Kriya meditation", note: "Never feeling it", small: "Three slow breaths, hands still."),
            ShelfItem(id: "g_sun", text: "Sun movements", note: "Heavy mornings", small: "One stretch toward the light."),
            ShelfItem(id: "g_nick", text: "Nick Moss daily meditation", note: "Later is fine", small: "Play it and hear the first minute."),
            ShelfItem(id: "g_neuro", text: "Functional neuro check-in", note: "Needs a little love and care", small: "One pathway, gently checked in.")
        ]
        let movement = [
            ShelfItem(id: "mv_push", text: "Push-ups", note: "however feels right", small: "Wall push-ups, or one on the floor."),
            ShelfItem(id: "mv_walk", text: "Walk outside", note: "at your pace", small: "To the end of the street and back."),
            ShelfItem(id: "mv_stairs", text: "Stairs", note: "if they're there", small: "One flight, slowly."),
            ShelfItem(id: "mv_stretch", text: "A long stretch", note: "no effort", small: "Reach up once, then let go.")
        ]
        let smallStarts = [
            ShelfItem(id: "ss_piano", text: "Five minutes of piano", note: "for fun", small: "Play one phrase, then stop if you like."),
            ShelfItem(id: "ss_read", text: "Read a few pages", note: "whatever's on the table", small: "Read one page."),
            ShelfItem(id: "ss_master", text: "Tick one thing off the master list", note: "just one", small: "Pick the smallest thing on it."),
            ShelfItem(id: "ss_beeper", text: "Reply to a couple of messages on Beeper", note: "briefly", small: "Open Beeper and answer one."),
            ShelfItem(id: "ss_email", text: "Clear a couple of emails", note: "not the whole inbox", small: "Archive two, not the whole inbox."),
            ShelfItem(id: "ss_wall", text: "Wall push-ups", note: "just a few", small: "Hands on the wall, bend your elbows, come back."),
            ShelfItem(id: "ss_shortwalk", text: "A short walk", note: "around the block", small: "Put on shoes and step outside.")
        ]
        return [
            Shelf(id: "sh_notfeeling", name: "Not feeling it", note: "Too much, or not today.", items: notFeeling, tone: "clay"),
            Shelf(id: "sh_keepclose", name: "Keep close", note: "Good for you, just not in the daily rhythm.", items: [], tone: "slate"),
            Shelf(id: "sh_movement", name: "Movement", note: "Bodies like a little movement. Take what you want; leave the rest.", items: movement, tone: "green"),
            Shelf(id: "sh_smallstarts", name: "Small starts", note: "Small, pleasant starts. Nothing to log.", items: smallStarts, tone: "amber")
        ]
    }
}