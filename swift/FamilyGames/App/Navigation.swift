import SwiftUI

enum Route: Hashable {
  case game(String)
  case gameSettings(String)
  /// `matchId == nil` records a new match.
  case match(gameId: String, matchId: String?)
}

/// Owns the navigation path so a screen deep in a game can return to the games list.
@MainActor @Observable
final class Router {
  var path: [Route] = []

  func popToRoot() { path = [] }
}

struct SettingsToolbar: ToolbarContent {
  var body: some ToolbarContent {
    ToolbarItem(placement: .automatic) {
      NavigationLink {
        SettingsView()
      } label: {
        Image(systemName: "gearshape")
      }
      .accessibilityLabel(L("settings"))
    }
  }
}
