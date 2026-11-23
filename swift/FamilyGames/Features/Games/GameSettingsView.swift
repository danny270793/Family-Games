import FamilyCore
import SwiftUI

struct GameSettingsView: View {
  @Environment(AppModel.self) private var model
  @Environment(Router.self) private var router
  let gameId: String

  @State private var showEdit = false
  @State private var showAddPlayer = false
  @State private var removing: GameMember?
  @State private var confirmDelete = false
  @State private var message: String?

  private var game: FamilyGame? { model.game(gameId) }

  var body: some View {
    Group {
      if let game {
        List {
          Section {
            Text(game.name).font(.title3.weight(.semibold))
          }
          Section {
            ForEach(game.members) { member in
              HStack {
                Text(String(member.email.first.map { String($0).uppercased() } ?? "?"))
                  .font(.headline).frame(width: 34, height: 34)
                  .background(Color.accentColor.opacity(0.18), in: .circle)
                Text(member.email)
                Spacer()
                Button(L("removePlayer"), systemImage: "xmark") { removing = member }
                  .labelStyle(.iconOnly).buttonStyle(.borderless)
              }
            }
            Button(L("addPlayer"), systemImage: "person.badge.plus") { showAddPlayer = true }
          } header: {
            Text(L("players"))
          } footer: {
            Text(L("playerHelp"))
          }
          Section {
            Button(L("editGame"), systemImage: "pencil") { showEdit = true }
            Button(L("deleteGame"), systemImage: "trash", role: .destructive) { confirmDelete = true }
          }
        }
      } else {
        ContentUnavailableView(L("unexpectedError"), systemImage: "questionmark")
      }
    }
    .navigationTitle(L("settings"))
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $showEdit) {
      if let game { GameFormSheet(game: game) }
    }
    .sheet(isPresented: $showAddPlayer) { AddPlayerSheet(gameId: gameId) }
    .confirmationDialog(L("removePlayer"), isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } }), titleVisibility: .visible) {
      Button(L("delete"), role: .destructive) {
        guard let member = removing else { return }
        Task { if let code = await model.removeMember(id: member.id) { message = gamesMessage(code) } }
      }
      Button(L("cancel"), role: .cancel) {}
    } message: {
      Text(L("removePlayerBody", removing?.email ?? ""))
    }
    .confirmationDialog(L("deleteGame"), isPresented: $confirmDelete, titleVisibility: .visible) {
      Button(L("delete"), role: .destructive) {
        Task {
          if let code = await model.deleteGame(id: gameId) {
            message = gamesMessage(code)
          } else {
            router.popToRoot()
          }
        }
      }
      Button(L("cancel"), role: .cancel) {}
    } message: {
      Text(L("deleteGameBody"))
    }
    .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
      Button(L("ok"), role: .cancel) {}
    }
  }
}

private struct AddPlayerSheet: View {
  @Environment(AppModel.self) private var model
  @Environment(\.dismiss) private var dismiss
  let gameId: String
  @State private var email = ""
  @State private var saving = false
  @State private var error: String?

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField(L("email"), text: $email)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit { Task { await submit() } }
            .onChange(of: email) { _, _ in error = nil }
        } footer: {
          Text(L("playerHelp"))
        }
        if let error { Section { Text(error).foregroundStyle(.red).font(.footnote) } }
      }
      .navigationTitle(L("addPlayer"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button(L("cancel")) { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button(L("addPlayer")) { Task { await submit() } }.disabled(saving)
        }
      }
    }
    .presentationDetents([.medium])
  }

  private func submit() async {
    let value = email.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty else {
      error = L("fieldRequired")
      return
    }
    saving = true
    defer { saving = false }
    if let code = await model.addMember(gameId: gameId, email: value) {
      error = gamesMessage(code)
    } else {
      dismiss()
    }
  }
}
