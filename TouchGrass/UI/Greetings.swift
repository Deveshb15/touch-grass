import Foundation

/// Copy for the block overlay. The title is personalized with the user's name and
/// rotates between blocks — `BlockController` picks a `seed` once per block, so all
/// displays agree and every new break shows a different line (stable within a block,
/// no jarring mid-break text changes). When no name is set, a generic pool is used.
enum BlockGreeting {
    /// Big title lines; `%@` is replaced with the name.
    private static let namedTitles: [String] = [
        "%@, go touch some grass.",
        "%@, you've been at it a while.",
        "step away, %@.",
        "look up, %@.",
        "the grass misses you, %@.",
        "breathe, %@.",
        "enough screen, %@.",
        "%@, your eyes want a horizon.",
        "grass o'clock, %@.",
        "%@, the real world is buffering.",
    ]

    /// The same sentiments, for when the name is blank.
    private static let anonymousTitles: [String] = [
        "go touch some grass.",
        "you've been at it a while.",
        "step away for a sec.",
        "look up.",
        "the grass misses you.",
        "just breathe.",
        "enough screen.",
        "your eyes want a horizon.",
        "grass o'clock.",
        "the real world is buffering.",
    ]

    /// Calm secondary lines under the countdown. Name-less by design.
    private static let helpers: [String] = [
        "look at something far away and let your eyes unclench.",
        "stretch, sip some water, stare at a tree.",
        "the work will still be here. it always is.",
        "no notifications out here — that's the whole point.",
        "twenty feet away, twenty seconds. go.",
        "stand up, roll your shoulders, drop your jaw.",
        "find a window. find the sky. that's it.",
        "you earned this one. don't argue with the grass.",
    ]

    static func title(name: String, seed: Int) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return pick(anonymousTitles, seed) }
        return pick(namedTitles, seed).replacingOccurrences(of: "%@", with: trimmed)
    }

    static func helper(name: String, seed: Int) -> String {
        // Offset so the helper doesn't lock-step with the title's index.
        pick(helpers, seed &+ 3)
    }

    private static func pick(_ pool: [String], _ seed: Int) -> String {
        guard !pool.isEmpty else { return "" }
        let i = ((seed % pool.count) + pool.count) % pool.count   // safe for negative seeds
        return pool[i]
    }
}
