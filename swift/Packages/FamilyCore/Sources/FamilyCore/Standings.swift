import Foundation

public struct ScoreLine: Sendable, Equatable {
  public var userId: String
  public var email: String
  public var points: Int

  public init(userId: String, email: String, points: Int) {
    self.userId = userId
    self.email = email
    self.points = points
  }
}

public struct PlayerResult: Sendable, Equatable {
  public var userId: String
  public var email: String
  public var points: Int
  public var won: Bool
  public var lost: Bool
}

public struct Standing: Sendable, Equatable, Identifiable {
  public var userId: String
  public var email: String
  public var wins: Int
  public var losses: Int
  public var points: Int
  public var id: String { userId }
}

public func sevenWondersTotal(
  maravilla: Int, monedas: Int, rojo: Int, azul: Int, amarillo: Int, verde: Int, morado: Int
) -> Int {
  maravilla + monedas + rojo + azul + amarillo + verde + morado
}

/// Highest score wins. Every lower score is a loss. Players tied for the
/// highest score each win, and none of them take a loss.
public func scoreResults(_ lines: [ScoreLine]) -> [PlayerResult] {
  guard let top = lines.map(\.points).max() else { return [] }
  return lines.map {
    PlayerResult(
      userId: $0.userId, email: $0.email, points: $0.points, won: $0.points == top, lost: $0.points < top)
  }
}

public func buildStandings(members: [ScoreLine], matches: [[ScoreLine]]) -> [Standing] {
  struct Tally {
    var email: String
    var wins = 0
    var losses = 0
    var points = 0
  }
  var byUser: [String: Tally] = [:]
  var order: [String] = []
  for member in members where byUser[member.userId] == nil {
    byUser[member.userId] = Tally(email: member.email)
    order.append(member.userId)
  }
  for match in matches {
    for result in scoreResults(match) {
      if byUser[result.userId] == nil {
        byUser[result.userId] = Tally(email: result.email)
        order.append(result.userId)
      }
      byUser[result.userId]!.points += result.points
      if result.won { byUser[result.userId]!.wins += 1 }
      if result.lost { byUser[result.userId]!.losses += 1 }
    }
  }
  return order.map { id in
    let tally = byUser[id]!
    return Standing(userId: id, email: tally.email, wins: tally.wins, losses: tally.losses, points: tally.points)
  }
  .sorted {
    if $0.wins != $1.wins { return $0.wins > $1.wins }
    if $0.losses != $1.losses { return $0.losses < $1.losses }
    if $0.points != $1.points { return $0.points > $1.points }
    return $0.email < $1.email
  }
}

public struct DatedMatch: Sendable {
  public var playedAt: Date
  public var scores: [ScoreLine]

  public init(playedAt: Date, scores: [ScoreLine]) {
    self.playedAt = playedAt
    self.scores = scores
  }
}

public struct WinSeries: Sendable, Equatable, Identifiable {
  public var userId: String
  public var email: String
  /// Index 0 is everyone at zero, before the first match. Each later index
  /// is the running win total after that match.
  public var cumulativeWins: [Int]
  public var id: String { userId }
}

/// One line per player. A match the player sat out keeps their total flat.
/// A loss resets nothing here; it simply does not add a win.
public func buildWinSeries(members: [ScoreLine], matches: [DatedMatch]) -> [WinSeries] {
  var totals: [String: Int] = [:]
  var emails: [String: String] = [:]
  var samples: [String: [Int]] = [:]
  for member in members {
    totals[member.userId] = 0
    emails[member.userId] = member.email
    samples[member.userId] = [0]
  }
  for match in matches {
    for result in scoreResults(match.scores) {
      if emails[result.userId] == nil { emails[result.userId] = result.email }
      if samples[result.userId] == nil {
        let prior = samples.values.first?.count ?? 1
        samples[result.userId] = Array(repeating: 0, count: prior)
        totals[result.userId] = 0
      }
      totals[result.userId, default: 0] += result.won ? 1 : 0
    }
    for userId in samples.keys {
      samples[userId]!.append(totals[userId] ?? 0)
    }
  }
  return samples.map {
    WinSeries(userId: $0.key, email: emails[$0.key] ?? "", cumulativeWins: $0.value)
  }
  .sorted { $0.email < $1.email }
}

public struct RangeHighlights: Sendable, Equatable {
  public var longestStreak = 0
  public var longestStreakEmails: [String] = []
  public var currentStreak = 0
  public var currentStreakEmails: [String] = []
  public var highestScore: Int?
  public var highestScoreEmails: [String] = []
  public var bestWinRatePercent: Int?
  public var bestWinRateEmails: [String] = []
  public var longestLosingStreak = 0
  public var longestLosingStreakEmails: [String] = []
  public var currentLosingStreak = 0
  public var currentLosingStreakEmails: [String] = []
  public var lowestScore: Int?
  public var lowestScoreEmails: [String] = []
  public var worstWinRatePercent: Int?
  public var worstWinRateEmails: [String] = []
}

/// Streaks count matches a player actually played. Sitting one out does not
/// break a run. A tie for first counts as a victory.
public func buildRangeHighlights(members: [ScoreLine], matches: [DatedMatch]) -> RangeHighlights {
  var emails: [String: String] = [:]
  for member in members { emails[member.userId] = member.email }
  var best: [String: Int] = [:]
  var current: [String: Int] = [:]
  var longestLoss: [String: Int] = [:]
  var currentLoss: [String: Int] = [:]
  var played: [String: Int] = [:]
  var wins: [String: Int] = [:]
  var highScore: Int?
  var highScoreEmails = Set<String>()
  var lowScore: Int?
  var lowScoreEmails = Set<String>()

  for match in matches {
    let results = scoreResults(match.scores)
    let matchHigh = results.map(\.points).max()
    let matchLow = results.map(\.points).min()
    if let matchHigh {
      if highScore == nil || matchHigh > highScore! {
        highScore = matchHigh
        highScoreEmails = Set(results.filter { $0.points == matchHigh }.map(\.email))
      } else if matchHigh == highScore {
        highScoreEmails.formUnion(results.filter { $0.points == matchHigh }.map(\.email))
      }
    }
    if let matchLow {
      if lowScore == nil || matchLow < lowScore! {
        lowScore = matchLow
        lowScoreEmails = Set(results.filter { $0.points == matchLow }.map(\.email))
      } else if matchLow == lowScore {
        lowScoreEmails.formUnion(results.filter { $0.points == matchLow }.map(\.email))
      }
    }
    for result in results {
      if emails[result.userId] == nil { emails[result.userId] = result.email }
      played[result.userId, default: 0] += 1
      let run = result.won ? (current[result.userId] ?? 0) + 1 : 0
      current[result.userId] = run
      let losses = result.lost ? (currentLoss[result.userId] ?? 0) + 1 : 0
      currentLoss[result.userId] = losses
      if result.won { wins[result.userId, default: 0] += 1 }
      if run > (best[result.userId] ?? 0) { best[result.userId] = run }
      if losses > (longestLoss[result.userId] ?? 0) { longestLoss[result.userId] = losses }
    }
  }

  var bestRate: Int?
  var worstRate: Int?
  var bestEmails: [String] = []
  var worstEmails: [String] = []
  for (userId, count) in played where count > 0 {
    let rate = Int((Double((wins[userId] ?? 0) * 100) / Double(count)).rounded())
    let email = emails[userId] ?? ""
    if bestRate == nil || rate > bestRate! {
      bestRate = rate
      bestEmails = [email]
    } else if rate == bestRate {
      bestEmails.append(email)
    }
    if worstRate == nil || rate < worstRate! {
      worstRate = rate
      worstEmails = [email]
    } else if rate == worstRate {
      worstEmails.append(email)
    }
  }

  let longest = leaders(best, emails)
  let active = leaders(current, emails)
  let longestLosses = leaders(longestLoss, emails)
  let activeLosses = leaders(currentLoss, emails)
  return RangeHighlights(
    longestStreak: longest.0, longestStreakEmails: longest.1,
    currentStreak: active.0, currentStreakEmails: active.1,
    highestScore: highScore, highestScoreEmails: highScoreEmails.sorted(),
    bestWinRatePercent: bestRate, bestWinRateEmails: bestEmails.sorted(),
    longestLosingStreak: longestLosses.0, longestLosingStreakEmails: longestLosses.1,
    currentLosingStreak: activeLosses.0, currentLosingStreakEmails: activeLosses.1,
    lowestScore: lowScore, lowestScoreEmails: lowScoreEmails.sorted(),
    worstWinRatePercent: worstRate, worstWinRateEmails: worstEmails.sorted())
}

private func leaders(_ values: [String: Int], _ emails: [String: String]) -> (Int, [String]) {
  var best = 0
  var names: [String] = []
  for (userId, value) in values {
    if value > best {
      best = value
      names = [emails[userId] ?? ""]
    } else if value == best && best > 0 {
      names.append(emails[userId] ?? "")
    }
  }
  return (best, names.sorted())
}
