import Foundation

enum SeedData {
    static let nickURL = "https://functional-neuro-health.mykajabi.com/products/neuro-pro-mastery-program/categories/2154161935/posts/2202064260"

    static func apply(to state: inout AppState) {
        let morningDefaults = [
            ListItem(id: "m_water", text: "Drink some water", note: nil, small: "One sip is enough.", url: nil),
            ListItem(id: "m_breakfast", text: "Breakfast outside, quiet", note: nil, small: "Open the door and step outside for a moment.", url: nil),
            ListItem(id: "m_sun", text: "One stretch toward the light", note: nil, small: "Reach up once, then let go.", url: nil)
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
            ShelfItem(id: "g_pause", text: "A quiet pause", note: "Too much, or not today", small: "One slow breath, eyes open or closed."),
            ShelfItem(id: "g_stretch", text: "One gentle stretch", note: "Heavy mornings", small: "Reach up once, then let go."),
            ShelfItem(id: "g_outside", text: "Step outside", note: "No phone needed", small: "Open the door and take one step."),
            ShelfItem(id: "g_music", text: "Listen to one calming track", note: "Sound can help", small: "Hear the first ten seconds."),
            ShelfItem(id: "g_checkin", text: "A kind check-in", note: "Needs a little care", small: "Notice how you feel, without fixing it.")
        ]
        let movement = [
            ShelfItem(id: "mv_push", text: "Push-ups", note: "however feels right", small: "Wall push-ups, or one on the floor."),
            ShelfItem(id: "mv_walk", text: "Walk outside", note: "at your pace", small: "To the end of the street and back."),
            ShelfItem(id: "mv_stairs", text: "Stairs", note: "if they're there", small: "One flight, slowly."),
            ShelfItem(id: "mv_stretch", text: "A long stretch", note: "no effort", small: "Reach up once, then let go.")
        ]
        let smallStarts = [
            ShelfItem(id: "ss_music", text: "Play one phrase", note: "for fun", small: "One note is enough."),
            ShelfItem(id: "ss_read", text: "Read one page", note: "whatever is nearby", small: "Read one paragraph."),
            ShelfItem(id: "ss_message", text: "Reply to one message", note: "briefly", small: "A short reply is enough."),
            ShelfItem(id: "ss_email", text: "Archive one email", note: "not the whole inbox", small: "One message, then stop."),
            ShelfItem(id: "ss_wall", text: "Wall push-ups", note: "just one", small: "One slow wall push-up."),
            ShelfItem(id: "ss_shortwalk", text: "A short walk", note: "around the block", small: "Put on shoes and step outside."),
            ShelfItem(id: "ss_water", text: "Drink a glass of water", note: "no rush", small: "One sip, if that is all.")
        ]
        return [
            Shelf(id: "sh_notfeeling", name: "Not feeling it", note: "Too much, or not today.", items: notFeeling, tone: "clay"),
            Shelf(id: "sh_keepclose", name: "Keep close", note: "Good for you, just not in the daily rhythm.", items: [], tone: "slate"),
            Shelf(id: "sh_movement", name: "Movement", note: "Bodies like a little movement. Take what you want; leave the rest.", items: movement, tone: "green"),
            Shelf(id: "sh_smallstarts", name: "Small starts", note: "Small, pleasant starts. Nothing to log.", items: smallStarts, tone: "amber")
        ]
    }
}