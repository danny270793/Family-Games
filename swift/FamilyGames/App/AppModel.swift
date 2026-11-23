import FamilyCore
import FamilyData
import SwiftUI

/// Signed-in data. Games come with their members, matches and scores in one query,
/// so every screen reads from `games` and a write just reloads it.
@MainActor @Observable
final class AppModel {
  private(set) var repo: FamilyRepository?
  private(set) var isSignedIn = false
  private(set) var games: [FamilyGame] = []
  private(set) var loading = false
  private(set) var loaded = false
  var loadError: String?
  var actionError: String?

  init() {
    repo = FamilyConfig.fromBundle().map { FamilyRepository(config: $0) }
    isSignedIn = repo?.hasSession ?? false
    if let repo {
      Task { await observeAuth(repo) }
    }
  }

  private func observeAuth(_ repo: FamilyRepository) async {
    for await (_, session) in repo.client.auth.authStateChanges {
      let signedIn = session != nil
      if signedIn != isSignedIn {
        isSignedIn = signedIn
        if !signedIn { clear() }
      }
    }
  }

  var userId: String? { repo?.userId }

  func game(_ id: String) -> FamilyGame? { games.first { $0.id == id } }

  func loadIfNeeded() async {
    guard isSignedIn, !loaded, !loading else { return }
    await reload()
  }

  func reload() async {
    guard let repo, isSignedIn else { return }
    loading = true
    defer { loading = false }
    do {
      games = try await repo.games()
      loadError = nil
      loaded = true
    } catch {
      FamilyLog.error("load failed", error)
      if !loaded { loadError = L("unexpectedError") }
    }
  }

  func signIn(email: String, password: String) async throws {
    guard let repo else { throw FamilyError.notConfigured }
    try await repo.signIn(email: email, password: password)
    isSignedIn = true
    loaded = false
    await reload()
  }

  func signOut() async {
    try? await repo?.signOut()
    isSignedIn = false
    clear()
  }

  private func clear() {
    games = []
    loaded = false
    loadError = nil
  }

  // MARK: Actions. Each returns nil on success or an error code (see `gamesMessage`).

  /// Returns the new game's id, or an error code.
  func createGame(name: String, type: GameType, description: String) async -> Result<String, GamesError> {
    await attempt("create game") { try await $0.createGame(name: name, type: type, description: description) }
  }

  func updateGame(id: String, name: String, type: GameType, description: String) async -> String? {
    await run("update game") { try await $0.updateGame(id: id, name: name, type: type, description: description) }
  }

  func deleteGame(id: String) async -> String? {
    await run("delete game") { try await $0.deleteGame(id: id) }
  }

  func addMember(gameId: String, email: String) async -> String? {
    await run("add member") { try await $0.addMember(gameId: gameId, email: email) }
  }

  func removeMember(id: String) async -> String? {
    await run("remove member") { try await $0.removeMember(id: id) }
  }

  func saveMatch(gameId: String, matchId: String?, playedAt: Date, scores: [ScoreDraft]) async -> String? {
    await run("save match") {
      try await $0.saveMatch(gameId: gameId, matchId: matchId, playedAt: playedAt, scores: scores)
    }
  }

  func deleteMatch(id: String) async -> String? {
    await run("delete match") { try await $0.deleteMatch(id: id) }
  }

  private func run<T>(_ label: String, _ work: (FamilyRepository) async throws -> T) async -> String? {
    switch await attempt(label, work) {
    case .success: nil
    case .failure(let error): error.code
    }
  }

  private func attempt<T>(_ label: String, _ work: (FamilyRepository) async throws -> T) async -> Result<T, GamesError> {
    guard let repo else { return .failure(GamesError("unexpected")) }
    do {
      let value = try await work(repo)
      await reload()
      return .success(value)
    } catch let error as GamesError {
      FamilyLog.error("\(label) failed: \(error.code)")
      return .failure(error)
    } catch {
      FamilyLog.error("\(label) failed", error)
      return .failure(GamesError("unexpected"))
    }
  }
}

func gamesMessage(_ code: String) -> String {
  switch code {
  case "user_not_found": L("playerNotFound")
  case "already_member": L("playerAlreadyAdded")
  case "at_least_two_players": L("atLeastTwoPlayers")
  case "name_required": L("fieldRequired")
  default: L("unexpectedError")
  }
}
