import 'package:family_games/data/games_repository.dart';
import 'package:family_games/l10n/app_localizations.dart';
import 'package:family_games/models/family_game.dart';
import 'package:family_games/pages/game_form_sheet.dart';
import 'package:family_games/theme/family_theme.dart';
import 'package:family_games/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key, required this.gameId});

  final String gameId;

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  FamilyGame? _game;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final game = await gamesRepository.getGame(widget.gameId);
      if (!mounted) return;
      setState(() {
        _game = game;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _edit(FamilyGame game) async {
    final result = await showGameFormSheet(context, game: game);
    if (result != null) await _load();
  }

  Future<void> _delete(FamilyGame game) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmSheet(
      context: context,
      title: l10n.deleteGame,
      body: l10n.deleteGameBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (ok != true || !mounted) return;
    try {
      await gamesRepository.deleteGame(game.id);
      if (mounted) context.go('/home');
    } on GamesException catch (error) {
      _snack(gamesErrorMessage(l10n, error.code));
    } catch (_) {
      _snack(l10n.unexpectedError);
    }
  }

  Future<void> _addPlayer() async {
    await showAppSheet<bool>(
      context: context,
      builder: (context) => _AddPlayerSheet(gameId: widget.gameId),
    );
    if (mounted) await _load();
  }

  Future<void> _removePlayer(GameMember member) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmSheet(
      context: context,
      title: l10n.removePlayer,
      body: l10n.removePlayerBody(member.email),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (ok != true || !mounted) return;
    try {
      await gamesRepository.removeMember(member.id);
      await _load();
    } on GamesException catch (error) {
      _snack(gamesErrorMessage(l10n, error.code));
    } catch (_) {
      _snack(l10n.unexpectedError);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = _game;
    final theme = Theme.of(context);
    return Scaffold(
      body: _loading && game == null
          ? const Center(child: CircularProgressIndicator())
          : game == null
          ? Center(child: Text(l10n.unexpectedError))
          : CustomScrollView(
              slivers: [
                SliverAppBar.medium(title: Text(l10n.settings)),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(game.name, style: theme.textTheme.titleLarge),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.players,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addPlayer,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: Text(l10n.addPlayer),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          l10n.playerHelp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final member in game.members)
                        _PlayerRow(
                          member: member,
                          onRemove: () => _removePlayer(member),
                        ),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(l10n.editGame),
                        onTap: () => _edit(game),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        leading: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                        title: Text(
                          l10n.deleteGame,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        onTap: () => _delete(game),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.member, required this.onRemove});

  final GameMember member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final initial = member.email.isEmpty ? '?' : member.email[0].toUpperCase();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(child: Text(initial)),
      title: Text(member.email),
      trailing: IconButton(
        tooltip: AppLocalizations.of(context).removePlayer,
        onPressed: onRemove,
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}

class _AddPlayerSheet extends StatefulWidget {
  const _AddPlayerSheet({required this.gameId});

  final String gameId;

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _controller.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l10n.fieldRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await gamesRepository.addMember(gameId: widget.gameId, email: email);
      if (mounted) Navigator.pop(context, true);
    } on GamesException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = gamesErrorMessage(l10n, error.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.unexpectedError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 22, 24, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addPlayer, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.playerHelp,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: l10n.email,
              errorText: _error,
              errorMaxLines: 2,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.addPlayer),
          ),
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
