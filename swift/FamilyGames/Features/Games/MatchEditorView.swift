import FamilyCore
import SwiftUI

/// What is typed for one player. Scores are text so a lone "-" is allowed while typing.
@MainActor @Observable
private final class PlayerDraft: Identifiable {
  let userId: String
  let email: String
  var selected: Bool
  var points = "0"
  var categories: [WonderCategory: String] = Dictionary(uniqueKeysWithValues: WonderCategory.allCases.map { ($0, "0") })

  var id: String { userId }

  init(member: GameMember, match: GameMatch?, type: GameType) {
    userId = member.userId
    email = member.email
    let score = match?.scores.first { $0.userId == member.userId }
    selected = match == nil || score != nil
    guard let score else { return }
    if type == .sevenWonders {
      if score.hasNoCategories, score.points != 0 {
        // Saved as a plain total: show it under the first category.
        categories[.maravilla] = "\(score.points)"
      } else {
        for category in WonderCategory.allCases { categories[category] = "\(score.value(category))" }
      }
    } else {
      points = "\(score.points)"
    }
  }

  func value(_ category: WonderCategory) -> Int { Self.parse(categories[category] ?? "") }
  var pointsValue: Int { Self.parse(points) }

  func total(for type: GameType) -> Int {
    type == .sevenWonders ? WonderCategory.allCases.reduce(0) { $0 + value($1) } : pointsValue
  }

  func isValid(for type: GameType) -> Bool {
    if type == .other { return Self.ok(points) }
    return WonderCategory.allCases.allSatisfy { Self.ok(categories[$0] ?? "") }
  }

  private static func ok(_ raw: String) -> Bool {
    let text = raw.trimmingCharacters(in: .whitespaces)
    return text.isEmpty || text == "-" || Int(text) != nil
  }

  private static func parse(_ raw: String) -> Int {
    let text = raw.trimmingCharacters(in: .whitespaces)
    return text.isEmpty || text == "-" ? 0 : Int(text) ?? 0
  }
}

struct MatchEditorView: View {
  @Environment(AppModel.self) private var model
  @Environment(\.dismiss) private var dismiss
  let gameId: String
  let matchId: String?

  @State private var drafts: [PlayerDraft] = []
  @State private var playedAt = Date.now
  @State private var ready = false
  @State private var saving = false
  @State private var message: String?
  @State private var confirmDelete = false

  private var game: FamilyGame? { model.game(gameId) }
  private var match: GameMatch? { game?.matches.first { $0.id == matchId } }

  var body: some View {
    Group {
      if let game, ready {
        form(game)
      } else if game == nil || (matchId != nil && match == nil && ready) {
        ContentUnavailableView(L("unexpectedError"), systemImage: "questionmark")
      } else {
        ProgressView()
      }
    }
    .navigationTitle(matchId == nil ? L("newMatch") : L("editMatch"))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if matchId != nil {
        ToolbarItem(placement: .primaryAction) {
          Button(L("deleteMatch"), systemImage: "trash", role: .destructive) { confirmDelete = true }
            .disabled(saving)
        }
      }
    }
    .task {
      guard !ready, let game else { return }
      drafts = game.members.map { PlayerDraft(member: $0, match: match, type: game.type) }
      playedAt = match?.playedAt ?? .now
      ready = true
    }
    .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
      Button(L("ok"), role: .cancel) {}
    }
    .confirmationDialog(L("deleteMatch"), isPresented: $confirmDelete, titleVisibility: .visible) {
      Button(L("delete"), role: .destructive) { Task { await remove() } }
      Button(L("cancel"), role: .cancel) {}
    } message: {
      Text(L("deleteMatchBody"))
    }
  }

  private func form(_ game: FamilyGame) -> some View {
    let selected = drafts.filter(\.selected)
    let results = scoreResults(selected.map { ScoreLine(userId: $0.userId, email: $0.email, points: $0.total(for: game.type)) })
    return Form {
      Section {
        DatePicker(L("matchDate"), selection: $playedAt, displayedComponents: .date)
        DatePicker(L("matchTime"), selection: $playedAt, displayedComponents: .hourAndMinute)
      }
      if !results.isEmpty {
        let winners = results.filter(\.won)
        Section {
          Label {
            VStack(alignment: .leading) {
              Text(winners.count > 1 ? L("tie") : L("leader")).font(.caption)
              Text(winners.map { "\(shortName($0.email)) · \($0.points)" }.joined(separator: ", ")).font(.headline)
            }
          } icon: {
            Image(systemName: "trophy.fill")
          }
        }
      }
      ForEach(drafts) { draft in
        PlayerScoreSection(
          draft: draft, type: game.type, won: results.contains { $0.userId == draft.userId && $0.won }, enabled: !saving)
      }
      Section {
        Button {
          Task { await save(game) }
        } label: {
          Group {
            if saving { ProgressView() } else { Text(L("save")).font(.headline) }
          }
          .frame(maxWidth: .infinity)
        }
        .disabled(saving)
      }
    }
  }

  private func save(_ game: FamilyGame) async {
    let selected = drafts.filter(\.selected)
    guard selected.count >= 2 else {
      message = L("atLeastTwoPlayers")
      return
    }
    guard selected.allSatisfy({ $0.isValid(for: game.type) }) else {
      message = L("pointsMustBeWhole")
      return
    }
    saving = true
    defer { saving = false }
    let scores = selected.map { draft -> ScoreDraft in
      if game.type == .sevenWonders {
        return ScoreDraft(
          userId: draft.userId, points: draft.total(for: game.type),
          maravilla: draft.value(.maravilla), monedas: draft.value(.monedas), rojo: draft.value(.rojo),
          azul: draft.value(.azul), amarillo: draft.value(.amarillo), verde: draft.value(.verde),
          morado: draft.value(.morado))
      }
      return ScoreDraft(userId: draft.userId, points: draft.pointsValue)
    }
    if let code = await model.saveMatch(gameId: game.id, matchId: matchId, playedAt: playedAt, scores: scores) {
      message = gamesMessage(code)
    } else {
      dismiss()
    }
  }

  private func remove() async {
    guard let matchId else { return }
    saving = true
    defer { saving = false }
    if await model.deleteMatch(id: matchId) == nil {
      dismiss()
    } else {
      message = L("unexpectedError")
    }
  }
}

private struct PlayerScoreSection: View {
  @Bindable var draft: PlayerDraft
  let type: GameType
  let won: Bool
  let enabled: Bool

  var body: some View {
    Section {
      Toggle(isOn: $draft.selected) {
        HStack {
          Text(draft.email).lineLimit(1)
          if draft.selected, won { Image(systemName: "trophy.fill").foregroundStyle(Color.accentColor).font(.caption) }
          Spacer()
          if draft.selected { Text("\(draft.total(for: type))").font(.title3.bold()).monospacedDigit() }
        }
      }
      .disabled(!enabled)
      if draft.selected {
        if type == .other {
          ScoreField(label: L("points"), enabled: enabled, text: $draft.points)
        } else {
          ForEach(WonderCategory.allCases, id: \.self) { category in
            ScoreField(
              label: wonderLabel(category), color: wonderColor(category), enabled: enabled,
              text: Binding(get: { draft.categories[category] ?? "" }, set: { draft.categories[category] = $0 }))
          }
        }
      }
    }
  }
}

/// A whole-number field that accepts a leading minus.
private struct ScoreField: View {
  let label: String
  var color: Color?
  let enabled: Bool
  @Binding var text: String

  var body: some View {
    HStack {
      if let color { Circle().fill(color).frame(width: 12, height: 12) }
      Text(label)
      TextField("0", text: $text)
        .keyboardType(.numbersAndPunctuation)
        .multilineTextAlignment(.trailing)
        .disabled(!enabled)
        .onChange(of: text) { _, value in
          let filtered = Self.filter(value)
          if filtered != value { text = filtered }
        }
    }
  }

  /// Keeps an optional leading "-" followed by digits.
  private static func filter(_ value: String) -> String {
    var result = ""
    for (index, character) in value.enumerated() {
      if character.isASCII, character.isNumber || (character == "-" && index == 0) { result.append(character) }
    }
    return result
  }
}
