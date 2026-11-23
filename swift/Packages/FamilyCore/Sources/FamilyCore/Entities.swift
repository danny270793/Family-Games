import Foundation

public enum GameType: String, CaseIterable, Sendable, Codable {
  case sevenWonders = "seven_wonders"
  case other

  public init(storage raw: String) {
    self = raw == "seven_wonders" ? .sevenWonders : .other
  }
}

public enum WonderCategory: String, CaseIterable, Sendable {
  case maravilla, monedas, rojo, azul, amarillo, verde, morado
}

public struct GameMember: Identifiable, Sendable, Equatable {
  public var id: String
  public var userId: String
  public var email: String
}

public struct MatchScore: Sendable, Equatable {
  public var userId: String
  public var email: String
  public var points: Int
  public var maravilla: Int
  public var monedas: Int
  public var rojo: Int
  public var azul: Int
  public var amarillo: Int
  public var verde: Int
  public var morado: Int

  public var line: ScoreLine { ScoreLine(userId: userId, email: email, points: points) }

  public func value(_ category: WonderCategory) -> Int {
    switch category {
    case .maravilla: maravilla
    case .monedas: monedas
    case .rojo: rojo
    case .azul: azul
    case .amarillo: amarillo
    case .verde: verde
    case .morado: morado
    }
  }

  /// Every seven-wonders category is zero (a match saved with just a total).
  public var hasNoCategories: Bool {
    WonderCategory.allCases.allSatisfy { value($0) == 0 }
  }
}

public struct GameMatch: Identifiable, Sendable, Equatable {
  public var id: String
  public var playedAt: Date
  public var scores: [MatchScore]

  public var results: [PlayerResult] { scoreResults(scores.map(\.line)) }
}

public struct FamilyGame: Identifiable, Sendable, Equatable {
  public var id: String
  public var name: String
  public var type: GameType
  public var description: String
  public var createdBy: String
  public var members: [GameMember]
  public var matches: [GameMatch]

  public var standings: [Standing] {
    buildStandings(
      members: members.map { ScoreLine(userId: $0.userId, email: $0.email, points: 0) },
      matches: matches.map { $0.scores.map(\.line) })
  }
}

/// What the app sends for one player when saving a match.
public struct ScoreDraft: Sendable, Equatable, Encodable {
  public var userId: String
  public var points: Int
  public var maravilla = 0
  public var monedas = 0
  public var rojo = 0
  public var azul = 0
  public var amarillo = 0
  public var verde = 0
  public var morado = 0

  public init(
    userId: String, points: Int, maravilla: Int = 0, monedas: Int = 0, rojo: Int = 0, azul: Int = 0,
    amarillo: Int = 0, verde: Int = 0, morado: Int = 0
  ) {
    self.userId = userId
    self.points = points
    self.maravilla = maravilla
    self.monedas = monedas
    self.rojo = rojo
    self.azul = azul
    self.amarillo = amarillo
    self.verde = verde
    self.morado = morado
  }

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case points, maravilla, monedas, rojo, azul, amarillo, verde, morado
  }
}

/// Failure codes raised by the `fg_*` functions. Mapped to messages by the app.
public struct GamesError: Error, Equatable, Sendable {
  public let code: String
  public init(_ code: String) { self.code = code }
}

// MARK: - Decoding the PostgREST payload

extension FamilyGame {
  /// Decodes `fg_games` rows selected with members, matches and scores embedded.
  public static func decodeList(_ data: Data) throws -> [FamilyGame] {
    let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
    return try rows.map(from)
  }

  public static func decodeOne(_ data: Data) throws -> FamilyGame {
    guard let row = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw GamesError("unexpected")
    }
    return try from(row)
  }

  static func from(_ row: [String: Any]) throws -> FamilyGame {
    guard let id = row["id"] as? String, let name = row["name"] as? String else { throw GamesError("unexpected") }
    let members = (row["fg_game_members"] as? [[String: Any]] ?? [])
      .compactMap { raw -> GameMember? in
        guard let id = raw["id"] as? String, let userId = raw["user_id"] as? String else { return nil }
        return GameMember(id: id, userId: userId, email: raw["email"] as? String ?? "")
      }
      .sorted { $0.email < $1.email }
    let matches = (row["fg_matches"] as? [[String: Any]] ?? [])
      .compactMap { raw -> GameMatch? in
        guard let id = raw["id"] as? String, let played = raw["played_at"] as? String,
          let playedAt = parseWallClock(played)
        else { return nil }
        let scores = (raw["fg_match_scores"] as? [[String: Any]] ?? []).compactMap { score -> MatchScore? in
          guard let userId = score["user_id"] as? String else { return nil }
          return MatchScore(
            userId: userId, email: score["email"] as? String ?? "", points: int(score["points"]),
            maravilla: int(score["maravilla"]), monedas: int(score["monedas"]), rojo: int(score["rojo"]),
            azul: int(score["azul"]), amarillo: int(score["amarillo"]), verde: int(score["verde"]),
            morado: int(score["morado"]))
        }
        return GameMatch(id: id, playedAt: playedAt, scores: scores)
      }
      .sorted { $0.playedAt != $1.playedAt ? $0.playedAt > $1.playedAt : $0.id > $1.id }
    return FamilyGame(
      id: id, name: name, type: GameType(storage: row["type"] as? String ?? ""),
      description: row["description"] as? String ?? "", createdBy: row["created_by"] as? String ?? "",
      members: members, matches: matches)
  }
}

private func int(_ value: Any?) -> Int {
  if let number = value as? NSNumber { return Int(number.doubleValue.rounded()) }
  if let string = value as? String, let parsed = Int(string) { return parsed }
  return 0
}

private let wallClock: DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = .current
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
  return formatter
}()

/// `played_at` is a `timestamp without time zone`: local wall-clock time, no offset.
/// Also accepts a value with an offset or fractional seconds.
public func parseWallClock(_ raw: String) -> Date? {
  let text = raw.replacingOccurrences(of: " ", with: "T")
  let hasZone = text.hasSuffix("Z") || text.range(of: #"[+-]\d{2}(:?\d{2})?$"#, options: .regularExpression) != nil
  if hasZone {
    let withFraction = ISO8601DateFormatter()
    withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = withFraction.date(from: text) { return date }
    let plain = ISO8601DateFormatter()
    plain.formatOptions = [.withInternetDateTime]
    return plain.date(from: text)
  }
  return wallClock.date(from: String(text.prefix(19)))
}

/// Local wall-clock `yyyy-MM-ddTHH:mm:ss` (no offset), matching the column type.
public func formatWallClock(_ date: Date) -> String {
  wallClock.string(from: date)
}
