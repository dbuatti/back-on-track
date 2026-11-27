import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct DumpSuggestion: Identifiable, Hashable {
    var id: String { text }
    let text: String
    let category: String
    let smallest: String
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
private struct GeneratedDumpPlan {
    @Guide(description: "A short list of distinct small things the person mentioned. Keep the original wording.")
    var items: [GeneratedDumpItem]
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedDumpItem {
    @Guide(description: "The small thing, in the person's own words. One short line.")
    var text: String
    @Guide(description: "One of: Around the house, Music, Journal, Study, Messages, Movement, Small things.")
    var category: String
}
#endif

enum BrainDumpIntelligence {
    static func organize(_ raw: String) async -> [DumpSuggestion] {
        let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return [] }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default
            if model.isAvailable {
                do {
                    let session = LanguageModelSession()
                    let response = try await session.respond(
                        generating: GeneratedDumpPlan.self,
                        options: GenerationOptions(samplingMode: .greedy)
                    ) {
                        "Turn this stream of consciousness into a short list of small things."
                        "Keep the person's own words. No judgement, no productivity language, no orders."
                        "Group them only by the simple categories given."
                        "If something is vague, keep it vague rather than inventing detail."
                        cleaned
                    }
                    return response.content.items
                        .map { DumpSuggestion(text: $0.text, category: $0.category, smallest: smallest(for: $0.category)) }
                        .filter { !$0.text.isEmpty }
                } catch {
                    return heuristic(cleaned)
                }
            }
        }
        #endif
        return heuristic(cleaned)
    }

    static func heuristic(_ raw: String) -> [DumpSuggestion] {
        let parts = raw
            .replacingOccurrences(of: "\n", with: ". ")
            .split(whereSeparator: { $0 == ";" || $0 == "." })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 2 }
        let source = parts.isEmpty ? [raw] : parts
        return source.map { text in
            let category = category(for: text)
            return DumpSuggestion(text: text, category: category, smallest: smallest(for: category))
        }
    }

    private static func category(for text: String) -> String {
        let t = text.lowercased()
        if t.contains(any: ["cloth", "laundry", "dish", "mug", "drawer", "tidy", "bin", "floor"]) { return "Around the house" }
        if t.contains(any: ["piano", "music", "gig", "compos", "practice", "song"]) { return "Music" }
        if t.contains(any: ["journal", "write", "note"]) { return "Journal" }
        if t.contains(any: ["study", "read", "learn", "course", "paper"]) { return "Study" }
        if t.contains(any: ["message", "email", "reply", "call"]) { return "Messages" }
        if t.contains(any: ["walk", "stretch", "move", "shake", "outside"]) { return "Movement" }
        return "Small things"
    }

    private static func smallest(for category: String) -> String {
        switch category {
        case "Around the house": return "Just one thing, put back."
        case "Music": return "Just one phrase or one note."
        case "Journal": return "Just one line."
        case "Study": return "Just one page or one paragraph."
        case "Messages": return "Just one short reply."
        case "Movement": return "Just one step or one stretch."
        default: return "Just notice it is there."
        }
    }
}

private extension String {
    func contains(any needles: [String]) -> Bool {
        needles.contains { self.contains($0) }
    }
}
