import Foundation

struct ProgramStep: Identifiable {
    let id: String
    let title: String
    let invitation: String
    let nick: String?
    let kind: String
    let optional: String?

    var kindLabel: String {
        switch kind {
        case "nick": return "Awareness"
        case "sleep": return "Sleep"
        case "body": return "Movement"
        case "connection": return "Connection"
        case "day": return "Everyday"
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
        default: return "One breath, then you can stop."
        }
    }
}

enum Program30 {
    static let nickURL = "https://functional-neuro-health.mykajabi.com/products/neuro-pro-mastery-program/categories/2154161935/posts/2202064260"

    static let steps: [ProgramStep] = [
        ProgramStep(id: "d01", title: "Press play once", invitation: "If you want, press play on the Nick Moss meditation and hear how it starts.", nick: "first 30 seconds", kind: "nick", optional: "You can stop at any point. That is still enough."),
        ProgramStep(id: "d02", title: "One quiet breath", invitation: "Notice one slow breath, then let it go. That's the whole invitation.", nick: nil, kind: "rest", optional: "If you like, take one more, then stop."),
        ProgramStep(id: "d03", title: "Nothing to play", invitation: "Today's invitation is to leave the meditation closed. One quiet breath is enough.", nick: nil, kind: "rest", optional: nil),
        ProgramStep(id: "d04", title: "One gentle stretch", invitation: "Reach up once, slowly, and let your arms come down again.", nick: nil, kind: "body", optional: "If you like, follow it with one more stretch, at your pace."),
        ProgramStep(id: "d05", title: "A little longer", invitation: "If you want, press play and stay for a minute and a half.", nick: "through the first minute and a half", kind: "nick", optional: "Or stop now — a minute is plenty."),
        ProgramStep(id: "d06", title: "Log waking up", invitation: "If you want, note the time you woke, just as it was.", nick: nil, kind: "sleep", optional: "If you like, add a line about how the night felt."),
        ProgramStep(id: "d07", title: "One small anchor", invitation: "Pick one anchor you fancy and give it a minute or two.", nick: nil, kind: "day", optional: "If you want, follow it with one more small anchor."),
        ProgramStep(id: "d08", title: "A short pause", invitation: "If you like, sit for half a minute without playing anything. Stopping early is fine.", nick: nil, kind: "rest", optional: nil),
        ProgramStep(id: "d09", title: "Two minutes of sound", invitation: "Press play when you like and let two minutes of it be enough.", nick: "through the first two minutes", kind: "nick", optional: "If you want, stay a little longer, then stop whenever."),
        ProgramStep(id: "d10", title: "One short message", invitation: "If you want, send one brief message to someone you like.", nick: nil, kind: "connection", optional: "If you like, reply to one more, whenever suits."),
        ProgramStep(id: "d11", title: "Three quiet minutes", invitation: "Open the meditation if you like and listen for three gentle minutes.", nick: "through the first three minutes", kind: "nick", optional: "If you want, choose a shorter stretch instead — two minutes is plenty."),
        ProgramStep(id: "d12", title: "Feel your feet", invitation: "Notice your feet on the floor for a few slow breaths.", nick: nil, kind: "body", optional: "If you like, press them gently into the floor, then let go."),
        ProgramStep(id: "d13", title: "Come back to something easy", invitation: "If you want, return to any earlier invitation and take just its smallest version.", nick: nil, kind: "rest", optional: nil),
        ProgramStep(id: "d14", title: "A simple bedtime note", invitation: "If you want, log your bed time when you get there.", nick: nil, kind: "sleep", optional: "If you like, add one word about the day before sleeping."),
        ProgramStep(id: "d15", title: "Four easy minutes", invitation: "Press play when it suits and let four minutes pass.", nick: "through the first four minutes", kind: "nick", optional: "If you want, rest your hands and stay a little longer."),
        ProgramStep(id: "d16", title: "Tidy one surface", invitation: "If you want, put three things back where they belong.", nick: nil, kind: "day", optional: "If you like, clear one more corner, then stop whenever."),
        ProgramStep(id: "d17", title: "Walk to the corner", invitation: "Step outside if you like and walk to the nearest corner.", nick: nil, kind: "body", optional: "If you want, go a little further, at your own pace."),
        ProgramStep(id: "d18", title: "Let it be shorter", invitation: "If you want, listen to two minutes or less. Two is plenty.", nick: "through the first two minutes", kind: "rest", optional: nil),
        ProgramStep(id: "d19", title: "Five minutes of rest", invitation: "If you want, press play and let five minutes be enough.", nick: "through the first five minutes", kind: "nick", optional: "If you like, stay for one more minute, then stop."),
        ProgramStep(id: "d20", title: "A kind check-in", invitation: "If you want, ask someone how they are and listen briefly.", nick: nil, kind: "connection", optional: "If you like, tell them one small thing about your day."),
        ProgramStep(id: "d21", title: "Keep wake time soft", invitation: "Log your wake time if you like, even after a rough night.", nick: nil, kind: "sleep", optional: "If you want, note one thing that made the morning easier."),
        ProgramStep(id: "d22", title: "Six unhurried minutes", invitation: "Open the meditation when you like and let it run six minutes.", nick: "through the first six minutes", kind: "nick", optional: "Turning it off early is fine. Five minutes is just as welcome."),
        ProgramStep(id: "d23", title: "Quiet, not listening", invitation: "If you like, sit without sound for a minute. Nothing else is needed.", nick: nil, kind: "rest", optional: nil),
        ProgramStep(id: "d24", title: "Read one page", invitation: "Open whatever is on the table and read one page.", nick: nil, kind: "day", optional: "If you like, read a few more pages, then stop whenever."),
        ProgramStep(id: "d25", title: "One long stretch", invitation: "Reach up slowly if you like and hold the stretch for a moment.", nick: nil, kind: "body", optional: "If you want, stretch one more time, gently."),
        ProgramStep(id: "d26", title: "Seven calm minutes", invitation: "Press play when you like and stay for seven gentle minutes.", nick: "through the first seven minutes", kind: "nick", optional: "If you like, sit quietly for a moment after it ends."),
        ProgramStep(id: "d27", title: "Share a small thing", invitation: "If you want, tell someone one small thing you noticed.", nick: nil, kind: "connection", optional: "If you like, let them answer whenever they can."),
        ProgramStep(id: "d28", title: "Five, or none", invitation: "If you want, listen to five minutes. If not, five quiet breaths are just as welcome.", nick: "through the first five minutes", kind: "rest", optional: nil),
        ProgramStep(id: "d29", title: "Lights low early", invitation: "If you want, lower the lights a little earlier tonight.", nick: nil, kind: "sleep", optional: "If you like, log your bed time and leave the rest."),
        ProgramStep(id: "d30", title: "Eight minutes, if you want", invitation: "Press play when you like and listen for eight minutes.", nick: "through the first eight minutes", kind: "nick", optional: "If you want, stop early and just sit quietly for a moment.")
    ]
}
