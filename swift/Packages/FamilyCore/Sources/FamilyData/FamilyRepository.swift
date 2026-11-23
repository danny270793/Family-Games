import FamilyCore
import Foundation
import Supabase

public struct FamilyConfig: Sendable {
  public var url: URL
  public var anonKey: String

  public init(url: URL, anonKey: String) {
    self.url = url
    self.anonKey = anonKey
  }

  public static func fromBundle(_ bundle: Bundle = .main) -> FamilyConfig? {
    guard let path = bundle.path(forResource: "FamilyConfig", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path) as? [String: String],
      let raw = dict["SUPABASE_URL"], let url = URL(string: raw),
      let key = dict["SUPABASE_ANON_KEY"], !key.isEmpty, !raw.contains("xxxx")
    else { return nil }
    return FamilyConfig(url: url, anonKey: key)
  }
}

public enum FamilyError: LocalizedError {
  case notSignedIn
  case notConfigured

  public var errorDescription: String? {
    switch self {
    case .notSignedIn: "Not signed in"
    case .notConfigured: "Family Games isn't configured"
    }
  }
}

public enum FamilyLog {
  public static func debug(_ message: String) {
    #if DEBUG
      print("FamilyGames: \(message)")
    #endif
  }

  public static func error(_ message: String, _ error: Error? = nil) {
    if let error {
      print("FamilyGames error: \(message): \(error)")
    } else {
      print("FamilyGames error: \(message)")
    }
  }
}

/// Reads and writes the `fg_*` schema. Writes go through the `fg_*` functions,
/// which check membership, so failures come back as short codes.
public final class FamilyRepository: Sendable {
  public let client: SupabaseClient

  static let gameSelect = "*, fg_game_members(*), fg_matches(*, fg_match_scores(*))"

  public init(config: FamilyConfig) {
    client = SupabaseClient(
      supabaseURL: config.url,
      supabaseKey: config.anonKey,
      options: SupabaseClientOptions(
        auth: .init(
          storage: KeychainLocalStorage(service: "io.github.danny270793.familygames.auth"),
          emitLocalSessionAsInitialSession: true
        )
      )
    )
  }

  public var userId: String? { client.auth.currentUser?.id.uuidString.lowercased() }
  public var email: String? { client.auth.currentUser?.email }
  public var hasSession: Bool { client.auth.currentSession != nil }

  // MARK: Session

  public func signIn(email: String, password: String) async throws {
    FamilyLog.debug("signIn")
    try await client.auth.signIn(email: email, password: password)
  }

  public func signOut() async throws {
    try await client.auth.signOut()
  }

  public func updateEmail(_ email: String) async throws {
    try await client.auth.update(user: UserAttributes(email: email))
  }

  public func updatePassword(_ password: String) async throws {
    try await client.auth.update(user: UserAttributes(password: password))
  }

  // MARK: Games

  public func games() async throws -> [FamilyGame] {
    let response = try await client.from("fg_games").select(Self.gameSelect)
      .order("created_at", ascending: false).execute()
    return try FamilyGame.decodeList(response.data)
  }

  public func game(id: String) async throws -> FamilyGame {
    let response = try await client.from("fg_games").select(Self.gameSelect).eq("id", value: id).single().execute()
    return try FamilyGame.decodeOne(response.data)
  }

  public func createGame(name: String, type: GameType, description: String) async throws -> String {
    try await guarded {
      let id: String = try await client.rpc(
        "fg_create_game",
        params: CreateGameParams(
          p_name: name.trimmingCharacters(in: .whitespacesAndNewlines), p_type: type.rawValue,
          p_description: description.trimmingCharacters(in: .whitespacesAndNewlines))
      ).execute().value
      return id
    }
  }

  public func updateGame(id: String, name: String, type: GameType, description: String) async throws {
    try await guarded {
      try await client.from("fg_games").update(
        UpdateGame(
          name: name.trimmingCharacters(in: .whitespacesAndNewlines), type: type.rawValue,
          description: description.trimmingCharacters(in: .whitespacesAndNewlines),
          updated_at: Date.now.formatted(.iso8601))
      ).eq("id", value: id).execute()
    }
  }

  public func deleteGame(id: String) async throws {
    try await guarded { try await client.rpc("fg_delete_game", params: ["p_game_id": id]).execute() }
  }

  public func addMember(gameId: String, email: String) async throws {
    try await guarded {
      try await client.rpc(
        "fg_add_member",
        params: ["p_game_id": gameId, "p_email": email.trimmingCharacters(in: .whitespacesAndNewlines)]
      ).execute()
    }
  }

  public func removeMember(id: String) async throws {
    try await guarded { try await client.rpc("fg_remove_member", params: ["p_member_id": id]).execute() }
  }

  @discardableResult
  public func saveMatch(gameId: String, matchId: String?, playedAt: Date, scores: [ScoreDraft]) async throws -> String {
    try await guarded {
      let id: String = try await client.rpc(
        "fg_save_match",
        params: SaveMatchParams(
          p_match_id: matchId, p_game_id: gameId, p_played_at: formatWallClock(playedAt), p_scores: scores)
      ).execute().value
      return id
    }
  }

  public func deleteMatch(id: String) async throws {
    try await guarded { try await client.rpc("fg_delete_match", params: ["p_match_id": id]).execute() }
  }

  /// Turns database errors into the short codes the app shows messages for.
  private func guarded<T>(_ work: () async throws -> T) async throws -> T {
    do {
      return try await work()
    } catch let error as PostgrestError {
      throw GamesError(Self.code(from: error.message))
    }
  }

  static func code(from message: String) -> String {
    let codes = [
      "user_not_found", "already_member", "at_least_two_players", "player_not_in_game",
      "not_a_member", "name_required", "match_not_found", "game_not_found",
    ]
    if let code = codes.first(where: { message.contains($0) }) { return code }
    if message.contains("23505") || message.contains("duplicate") { return "already_member" }
    return "unexpected"
  }
}

// MARK: - Payloads

private struct CreateGameParams: Encodable {
  var p_name: String
  var p_type: String
  var p_description: String
}

private struct UpdateGame: Encodable {
  var name: String
  var type: String
  var description: String
  var updated_at: String
}

private struct SaveMatchParams: Encodable {
  var p_match_id: String?
  var p_game_id: String
  var p_played_at: String
  var p_scores: [ScoreDraft]

  enum CodingKeys: String, CodingKey { case p_match_id, p_game_id, p_played_at, p_scores }

  func encode(to encoder: Encoder) throws {
    var c = encoder.container(keyedBy: CodingKeys.self)
    if let p_match_id { try c.encode(p_match_id, forKey: .p_match_id) } else { try c.encodeNil(forKey: .p_match_id) }
    try c.encode(p_game_id, forKey: .p_game_id)
    try c.encode(p_played_at, forKey: .p_played_at)
    try c.encode(p_scores, forKey: .p_scores)
  }
}
