import FamilyCore
import SwiftUI

/// Creates a game, or edits `game`. `onDone` gets the new game's id (nil when editing).
struct GameFormSheet: View {
  @Environment(AppModel.self) private var model
  @Environment(\.dismiss) private var dismiss
  let game: FamilyGame?
  var onDone: (String?) -> Void = { _ in }

  @State private var name = ""
  @State private var type: GameType = .other
  @State private var details = ""
  @State private var saving = false
  @State private var error: String?

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField(L("gameName"), text: $name).textInputAutocapitalization(.words)
          Picker(L("gameType"), selection: $type) {
            Text(L("gameTypeSevenWonders")).tag(GameType.sevenWonders)
            Text(L("gameTypeOther")).tag(GameType.other)
          }
          .pickerStyle(.segmented)
          TextField(L("gameDescription"), text: $details, axis: .vertical)
            .lineLimit(2...4)
        }
        if let error { Section { Text(error).foregroundStyle(.red).font(.footnote) } }
      }
      .navigationTitle(game == nil ? L("newGame") : L("editGame"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button(L("cancel")) { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button(game == nil ? L("createGame") : L("save")) { Task { await save() } }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || saving)
        }
      }
      .onAppear {
        guard let game else { return }
        name = game.name
        type = game.type
        details = game.description
      }
    }
    .presentationDetents([.medium, .large])
  }

  private func save() async {
    saving = true
    defer { saving = false }
    if let game {
      if let code = await model.updateGame(id: game.id, name: name, type: type, description: details) {
        error = gamesMessage(code)
        return
      }
      onDone(nil)
    } else {
      switch await model.createGame(name: name, type: type, description: details) {
      case .success(let id): onDone(id)
      case .failure(let failure):
        error = gamesMessage(failure.code)
        return
      }
    }
    dismiss()
  }
}
