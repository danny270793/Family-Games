import FamilyCore
import SwiftUI

/// Signed-in shell: the games list is the root of a navigation stack.
struct GamesRootView: View {
  @Environment(AppModel.self) private var model
  @State private var router = Router()

  var body: some View {
    NavigationStack(path: $router.path) {
      GamesView()
        .navigationDestination(for: Route.self) { route in
          switch route {
          case .game(let id): GameDetailView(gameId: id)
          case .gameSettings(let id): GameSettingsView(gameId: id)
          case .match(let gameId, let matchId): MatchEditorView(gameId: gameId, matchId: matchId)
          }
        }
    }
    .environment(router)
    .task { await model.loadIfNeeded() }
  }
}

struct GamesView: View {
  @Environment(AppModel.self) private var model
  @Environment(Router.self) private var router
  @State private var showForm = false

  var body: some View {
    Group {
      if model.loading && !model.loaded {
        ProgressView()
      } else if let error = model.loadError, model.games.isEmpty {
        ContentUnavailableView {
          Label(error, systemImage: "icloud.slash")
        } actions: {
          Button(L("retry")) { Task { await model.reload() } }
        }
      } else if model.games.isEmpty {
        ContentUnavailableView {
          Label(L("gamesEmptyTitle"), systemImage: "gamecontroller")
        } description: {
          Text(L("gamesEmptyBody"))
        } actions: {
          Button(L("newGame")) { showForm = true }.buttonStyle(.borderedProminent)
        }
      } else {
        List(model.games) { game in
          NavigationLink(value: Route.game(game.id)) { GameCard(game: game) }
        }
      }
    }
    .navigationTitle(L("appTitle"))
    .toolbar {
      SettingsToolbar()
      ToolbarItem(placement: .primaryAction) {
        Button(L("newGame"), systemImage: "plus") { showForm = true }
      }
    }
    .refreshable { await model.reload() }
    .sheet(isPresented: $showForm) {
      GameFormSheet(game: nil) { id in
        if let id { router.path.append(.game(id)) }
      }
    }
  }
}

private struct GameCard: View {
  @Environment(AppModel.self) private var model
  let game: FamilyGame

  private var record: Standing? { game.standings.first { $0.userId == model.userId } }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        TypeChip(type: game.type)
        Spacer()
        Text(LP("playersCount", game.members.count)).font(.caption).foregroundStyle(.secondary)
      }
      Text(game.name).font(.title3.weight(.semibold))
      if !game.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Text(game.description).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
      }
      Label(
        record.map { "\(L("wins")) \($0.wins)  ·  \(L("losses")) \($0.losses)" } ?? LP("matchesCount", game.matches.count),
        systemImage: "trophy"
      )
      .font(.subheadline.weight(.medium))
      .foregroundStyle(Color.accentColor)
    }
    .padding(.vertical, 6)
  }
}
