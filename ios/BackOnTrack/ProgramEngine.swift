import Foundation

struct ProgramInvitation: Identifiable {
    let id: String
    let title: String
    let invitation: String
    let nick: String?
    let kind: String
    let optional: String?
    let phase: Int

    var kindLabel: String {
        switch kind {
        case "nick": return "Awareness"
        case "sleep": return "Sleep"
        case "body": return "Movement"
        case "connection": return "Connection"
        case "day": return "Everyday"
        case "focus": return "Your focus"
        default: return "Quiet repeat"
        }
    }

    var smaller: String {
        switch kind {
        case "nick": return "Just open the page. No listening needed — that's enough."
        case "sleep": return "Just notice what time it is. That's all."
        case "body": return "Just feel your feet for a moment."
        case "connection": return "Just think of someone. No message needed."
        case "day": return "Just look around once. No need to do anything."
        case "focus": return "Pause for one breath before choosing. That is enough."
        default: return "One breath, then you can stop."
        }
    }
}

struct ProgramPhase {
    let title: String
    let subtitle: String
}

enum Program {
    static let nickURL = "https://functional-neuro-health.mykajabi.com/products/neuro-pro-mastery-program/categories/2154161935/posts/2202064260"

    static let phases: [ProgramPhase] = [
        ProgramPhase(title: "Arrive", subtitle: "Small ways back to yourself."),
        ProgramPhase(title: "Body & sleep", subtitle: "Care without optimisation."),
        ProgramPhase(title: "Attention & anchors", subtitle: "One thing at a time."),
        ProgramPhase(title: "Connection & meaning", subtitle: "Let support be part of the rhythm."),
        ProgramPhase(title: "Your focus", subtitle: "A gentler relationship with what pulls you in."),
        ProgramPhase(title: "Integration", subtitle: "Build a rhythm that is yours.")
    ]

    static let steps: [ProgramInvitation] = {
        var all: [ProgramInvitation] = []
        func add(_ phase: Int, _ items: [(String, String, String, String?, String?)]) {
            for (index, item) in items.enumerated() {
                all.append(ProgramInvitation(
                    id: "p\(phase + 1)_\(String(format: "%02d", index + 1))",
                    title: item.0,
                    invitation: item.1,
                    nick: item.3,
                    kind: item.2,
                    optional: item.4,
                    phase: phase
                ))
            }
        }

        add(0, [
            ("Press play once", "If you want, hear how the Nick Moss meditation begins.", "nick", "first 30 seconds", "You can stop at any point."),
            ("One quiet breath", "Notice one slow breath, then let it go.", "rest", nil, "One more is welcome, not required."),
            ("Nothing to play", "Leave the meditation closed. One quiet breath is enough.", "rest", nil, nil),
            ("Feel your feet", "Notice where your feet meet the floor.", "body", nil, "Press them gently once, then let go."),
            ("Look around once", "Name three things you can see. No need to do anything with them.", "day", nil, nil),
            ("One small anchor", "Pick one tiny thing from your day and give it a minute.", "day", nil, "Stop whenever it feels like enough."),
            ("A short pause", "Sit for half a minute without sound or input.", "rest", nil, "Stopping early is fine."),
            ("Step outside", "Open the door and take one step into the air.", "body", nil, "Go to the corner only if you want."),
            ("One short message", "Send one brief message to someone you like.", "connection", nil, "No reply is needed."),
            ("Notice what helped", "Think of one small thing that made today easier.", "day", nil, "You can leave it unspoken.")
        ])

        add(1, [
            ("Reach up once", "Stretch slowly toward the light, then let your arms come down.", "body", nil, "One more only if it feels good."),
            ("Drink some water", "Take one sip and notice the temperature.", "body", nil, "That is the whole invitation."),
            ("Daylight, briefly", "Stand near a window or step outside for a moment.", "body", nil, "No walk required."),
            ("Log waking up", "Note the time you woke, just as it was.", "sleep", nil, "A rough night still counts as information."),
            ("Lower the lights", "Make the room a little dimmer for one minute.", "sleep", nil, "No perfect bedtime routine needed."),
            ("Put the phone down", "Place it out of reach for one slow breath.", "sleep", nil, "You can pick it up whenever you choose."),
            ("A bedtime note", "Write one word about the day before sleeping.", "sleep", nil, "One word is plenty."),
            ("Gentle movement", "Move one part of your body in a way that feels kind.", "body", nil, "Stillness is also welcome."),
            ("Rest without earning it", "Pause before finishing anything else.", "rest", nil, "Nothing needs to be completed first."),
            ("A kinder wake-up", "Tomorrow, notice one thing that makes waking a little easier.", "sleep", nil, "No new routine required.")
        ])

        add(2, [
            ("One page", "Open whatever is nearby and read one page.", "day", nil, "One paragraph is enough."),
            ("One surface", "Put one thing back where it belongs.", "day", nil, "Stop after one thing."),
            ("One phrase", "Play, draw, sing or make one small thing for fun.", "day", nil, "It does not need to be good."),
            ("Close one loop", "Finish the smallest open loop you can see.", "day", nil, "Leaving it open is also allowed."),
            ("One tab", "Close or minimise one extra tab.", "focus", nil, "The work will still be there."),
            ("A short focus", "Choose one task and give it two unhurried minutes.", "day", nil, "A timer is optional."),
            ("Write the next step", "Leave yourself one clear sentence for later.", "focus", nil, "Vague is fine if it helps you stop."),
            ("No phone for one breath", "Let one breath happen before checking anything.", "focus", nil, "You can check afterwards."),
            ("Notice the urge", "When you want to switch tasks, pause for one breath first.", "focus", nil, "No need to resist the urge perfectly."),
            ("Review without scoring", "Look at today and notice one thing that was enough.", "day", nil, "No grade, no catch-up.")
        ])

        add(3, [
            ("Ask someone how they are", "Send one kind check-in and listen briefly.", "connection", nil, "A one-line reply is enough."),
            ("Say one small thing", "Tell someone one small thing you noticed.", "connection", nil, "They can answer whenever."),
            ("Thank someone", "Name one thing you appreciate about someone.", "connection", nil, "You do not have to send it."),
            ("Ask for one small thing", "Let one person know what would help today.", "connection", nil, "Asking quietly still counts."),
            ("Shared quiet", "Spend a few minutes near someone without needing to entertain.", "connection", nil, "A message or call works too."),
            ("One boundary", "Notice one thing you would like to say no to.", "connection", nil, "No message required."),
            ("Kindness inward", "Speak to yourself as you would to someone tired.", "rest", nil, "One sentence is enough."),
            ("Notice a value", "Name one thing you want your day to make room for.", "day", nil, "It can be very small."),
            ("Make room for support", "Choose one person, place or practice that steadies you.", "connection", nil, "No action needed."),
            ("Quiet company", "Let yourself be around something or someone calming.", "rest", nil, "Silence is welcome.")
        ])

        add(4, [
            ("Notice the pull", "When {focus} starts pulling you in, pause for one breath before deciding.", "focus", nil, "No need to fight the pull."),
            ("Name the next step", "Write one next step for {focus}, then stop.", "focus", nil, "A rough note is enough."),
            ("Close the loop", "Close the {focus} window, tab or app for one minute.", "focus", nil, "You can reopen it whenever you choose."),
            ("Choose a stopping cue", "Pick a phrase: ‘This is enough for now.’", "focus", nil, "Say it silently if that is easier."),
            ("Change the space", "Put one cue for {focus} out of reach for ten minutes.", "focus", nil, "Small changes count."),
            ("Delay by one breath", "Wait one slow breath before returning to {focus}.", "focus", nil, "Then choose freely."),
            ("Stop before tired", "End {focus} while you still have a little energy.", "focus", nil, "There is no perfect stopping point."),
            ("No catch-up", "Missed {focus} time does not need to be repaid.", "rest", nil, "Let the day be enough."),
            ("One small alternative", "Choose one small thing that is not {focus}.", "focus", nil, "It can last one minute."),
            ("Rest without finishing", "Take a pause without completing {focus} first.", "rest", nil, "The unfinished part can wait.")
        ])

        add(5, [
            ("Your own rhythm", "Notice which part of this sequence felt most supportive.", "day", nil, "No need to explain it."),
            ("Keep one small thing", "Choose one invitation to keep using after the sequence.", "day", nil, "One is enough."),
            ("Sleep kindness", "Notice one way to make bedtime a little less demanding.", "sleep", nil, "No perfect routine needed."),
            ("Movement kindness", "Choose one way to move that feels welcoming.", "body", nil, "Stillness is welcome too."),
            ("Connection kindness", "Let one person know support matters.", "connection", nil, "A small message is enough."),
            ("A quiet minute", "Sit without sound or input for one minute.", "rest", nil, "Thirty seconds is plenty."),
            ("Return to a favourite", "Repeat any earlier invitation in its smallest form.", "rest", nil, "Nothing new is required."),
            ("Plan for a hard day", "Choose one support you want easy to reach when things feel heavy.", "day", nil, "Prepare gently, not perfectly."),
            ("Nothing to score", "Look back without grading yourself.", "rest", nil, "You did not need to earn rest."),
            ("An open invitation", "Choose one kind thing to carry forward. There is no final task.", "day", nil, "Stop here whenever you are ready.")
        ])
        return all
    }()

    static func effectiveStep(state: AppState, index: Int) -> ProgramInvitation {
        let safeIndex = min(max(index, 0), steps.count - 1)
        let base = steps[safeIndex]
        let p = state.settings.program30
        let pace = p.pace ?? "gentle"
        let mood = state.days[todayKey()]?.mood
        let gap = daysSince(p.lastDoneAt)
        let focus = state.settings.personalization?.focusLabel ?? "this pull"

        var title = base.title.replacingOccurrences(of: "{focus}", with: focus)
        var invitation = base.invitation.replacingOccurrences(of: "{focus}", with: focus)
        var optional = base.optional
        var id = base.id

        if gap >= 3 {
            id = "return_" + base.id
            title = "Come back gently"
            invitation = "Your place is right where you left it. Take one breath, one look around, or nothing at all. Nothing to catch up on."
            optional = "When this feels like enough, the next invitation can wait until you are ready."
        } else if pace == "minimal" || mood == "low" {
            invitation = base.smaller.replacingOccurrences(of: "{focus}", with: focus)
            optional = mood == "low" ? "If even this feels like too much, stop here. That is allowed." : optional
        }

        return ProgramInvitation(id: id, title: title, invitation: invitation, nick: base.nick, kind: base.kind, optional: optional, phase: base.phase)
    }

    static func daysSince(_ value: String) -> Int {
        guard !value.isEmpty else { return 0 }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: value) else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: date), to: Calendar.current.startOfDay(for: Date())).day ?? 0)
    }
}
