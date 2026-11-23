import FamilyCore
import SwiftUI

struct GameDetailView: View {
  @Environment(AppModel.self) private var model
  @Environment(Router.self) private var router
  let gameId: String
  @State private var noPlayers = false

  private var game: FamilyGame? { model.game(gameId) }

  var body: some View {
    Group {
      if let game {
        List {
          Section {
            TypeChip(type: game.type)
            if !game.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              Text(game.description).foregroundStyle(.secondary)
            }
          }
          .listRowBackground(Color.clear)
          Section { StatisticsSection(game: game) }
          Section(L("matches")) {
            if game.matches.isEmpty {
              Text(L("noMatches")).foregroundStyle(.secondary)
            }
            ForEach(game.matches) { match in
              NavigationLink(value: Route.match(gameId: game.id, matchId: match.id)) { MatchRow(match: match) }
            }
          }
        }
        .safeAreaInset(edge: .bottom) {
          Button {
            if game.members.count < 2 {
              noPlayers = true
            } else {
              router.path.append(.match(gameId: game.id, matchId: nil))
            }
          } label: {
            Label(L("newMatch"), systemImage: "plus").font(.headline).frame(maxWidth: .infinity)
          }
          .buttonStyle(.glassProminent)
          .controlSize(.large)
          .padding(.horizontal, 20).padding(.bottom, 8)
        }
      } else {
        ContentUnavailableView(L("unexpectedError"), systemImage: "questionmark")
      }
    }
    .navigationTitle(game?.name ?? "")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      if game != nil {
        ToolbarItem(placement: .primaryAction) {
          Button(L("settings"), systemImage: "gearshape") { router.path.append(.gameSettings(gameId)) }
        }
      }
    }
    .refreshable { await model.reload() }
    .alert(L("noPlayers"), isPresented: $noPlayers) {
      Button(L("ok"), role: .cancel) {}
    }
  }
}

private struct MatchRow: View {
  let match: GameMatch

  var body: some View {
    let ranked = match.results.sorted { $0.points > $1.points }
    let winners = ranked.filter(\.won).map(\.email)
    VStack(alignment: .leading, spacing: 3) {
      Text(match.playedAt.formatted(date: .abbreviated, time: .shortened)).font(.headline)
      Text("\(winners.count > 1 ? L("tie") : L("winner")): \(winners.joined(separator: ", "))")
        .font(.subheadline).foregroundStyle(.secondary)
      Text(ranked.map { "\(shortName($0.email)) \($0.points)" }.joined(separator: "  ·  "))
        .font(.subheadline).lineLimit(2)
    }
    .padding(.vertical, 2)
  }
}
