import 'package:family_games/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/theme/family_theme.dart';
import '../features/games/domain/entities/family_game.dart';
import '../features/games/domain/entities/games_exception.dart';
import '../features/games/domain/usecases/create_game_usecase.dart';
import '../features/games/domain/usecases/update_game_usecase.dart';
import 'app_sheet.dart';

Future<String?> showGameFormSheet(BuildContext context, {FamilyGame? game}) {
  return showAppSheet<String>(
    context: context,
    builder: (context) => _GameFormSheet(game: game),
  );
}

class _GameFormSheet extends StatefulWidget {
  const _GameFormSheet({this.game});

  final FamilyGame? game;

  @override
  State<_GameFormSheet> createState() => _GameFormSheetState();
}

class _GameFormSheetState extends State<_GameFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late GameType _type;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.game?.name ?? '');
    _description = TextEditingController(text: widget.game?.description ?? '');
    _type = widget.game?.type ?? GameType.other;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      if (widget.game == null) {
        final id = await getIt<CreateGameUsecase>()(
          name: _name.text,
          type: _type,
          description: _description.text,
        );
        if (mounted) Navigator.of(context).pop(id);
      } else {
        await getIt<UpdateGameUsecase>()(
          id: widget.game!.id,
          name: _name.text,
          type: _type,
          description: _description.text,
        );
        if (mounted) Navigator.of(context).pop('updated');
      }
    } on GamesException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(gamesErrorMessage(l10n, error.code))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.unexpectedError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.game == null ? l10n.newGame : l10n.editGame,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              autofocus: widget.game == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.gameName),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.gameType, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<GameType>(
              segments: [
                ButtonSegment(
                  value: GameType.sevenWonders,
                  label: Text(l10n.gameTypeSevenWonders),
                ),
                ButtonSegment(
                  value: GameType.other,
                  label: Text(l10n.gameTypeOther),
                ),
              ],
              selected: {_type},
              onSelectionChanged: _saving
                  ? null
                  : (value) => setState(() => _type = value.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.gameDescription,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.game == null ? l10n.createGame : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
