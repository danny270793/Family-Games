import 'package:family_games/data/games_repository.dart';
import 'package:family_games/l10n/app_localizations.dart';
import 'package:family_games/logic/standings.dart';
import 'package:family_games/models/family_game.dart';
import 'package:family_games/theme/family_theme.dart';
import 'package:family_games/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key, required this.gameId, this.matchId});

  final String gameId;
  final String? matchId;

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  FamilyGame? _game;
  GameMatch? _match;
  DateTime _playedAt = DateTime.now();
  final List<_Draft> _drafts = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final game = await gamesRepository.getGame(widget.gameId);
      GameMatch? match;
      if (widget.matchId != null) {
        for (final row in game.matches) {
          if (row.id == widget.matchId) {
            match = row;
            break;
          }
        }
      }
      final drafts = [
        for (final member in game.members)
          _Draft.fromMember(member, match, game.type),
      ];
      if (!mounted) return;
      setState(() {
        _game = game;
        _match = match;
        _playedAt = match?.playedAt ?? DateTime.now();
        _drafts
          ..clear()
          ..addAll(drafts);
        _loading = false;
        _error = match == null && widget.matchId != null ? 'missing' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'load';
      });
    }
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  int _total(_Draft draft) {
    final game = _game;
    if (game == null) return 0;
    if (game.type == GameType.sevenWonders) {
      return sevenWondersTotal(
        maravilla: draft.value(WonderCategory.maravilla),
        monedas: draft.value(WonderCategory.monedas),
        rojo: draft.value(WonderCategory.rojo),
        azul: draft.value(WonderCategory.azul),
        amarillo: draft.value(WonderCategory.amarillo),
        verde: draft.value(WonderCategory.verde),
        morado: draft.value(WonderCategory.morado),
      );
    }
    return draft.pointsValue();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _playedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _playedAt = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final game = _game;
    if (game == null) return;
    final selected = _drafts.where((draft) => draft.selected).toList();
    if (selected.length < 2) {
      _snack(l10n.atLeastTwoPlayers);
      return;
    }
    for (final draft in selected) {
      if (!draft.isValid(game.type)) {
        _snack(l10n.pointsMustBeWhole);
        return;
      }
    }
    setState(() => _saving = true);
    try {
      await gamesRepository.saveMatch(
        gameId: game.id,
        matchId: _match?.id,
        playedAt: _playedAt,
        scores: [
          for (final draft in selected)
            game.type == GameType.sevenWonders
                ? ScoreDraft(
                    userId: draft.userId,
                    points: _total(draft),
                    maravilla: draft.value(WonderCategory.maravilla),
                    monedas: draft.value(WonderCategory.monedas),
                    rojo: draft.value(WonderCategory.rojo),
                    azul: draft.value(WonderCategory.azul),
                    amarillo: draft.value(WonderCategory.amarillo),
                    verde: draft.value(WonderCategory.verde),
                    morado: draft.value(WonderCategory.morado),
                  )
                : ScoreDraft(userId: draft.userId, points: draft.pointsValue()),
        ],
      );
      if (mounted) context.pop(true);
    } on GamesException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack(gamesErrorMessage(l10n, error.code));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack(l10n.unexpectedError);
    }
  }

  Future<void> _delete() async {
    final match = _match;
    if (match == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmSheet(
      context: context,
      title: l10n.deleteMatch,
      body: l10n.deleteMatchBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (ok != true || !mounted) return;
    try {
      await gamesRepository.deleteMatch(match.id);
      if (mounted) context.pop(true);
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _game == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.unexpectedError)),
      );
    }
    final game = _game!;
    final selected = _drafts.where((draft) => draft.selected).toList();
    final lines = [
      for (final draft in selected)
        ScoreLine(userId: draft.userId, email: draft.email, points: _total(draft)),
    ];
    final results = scoreResults(lines);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(_playedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(_match == null ? l10n.newMatch : l10n.editMatch),
        actions: [
          if (_match != null)
            IconButton(
              tooltip: l10n.deleteMatch,
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.matchDate),
            subtitle: Text(dateLabel),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _saving ? null : _pickDate,
          ),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LeaderBanner(results: results),
            ),
          ],
          const SizedBox(height: 16),
          for (final draft in _drafts) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PlayerScoreCard(
                draft: draft,
                type: game.type,
                total: _total(draft),
                won: results.any((row) => row.userId == draft.userId && row.won),
                enabled: !_saving,
                onChanged: () => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderBanner extends StatelessWidget {
  const _LeaderBanner({required this.results});

  final List<PlayerResult> results;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final winners = results.where((row) => row.won).toList();
    final label = winners.length > 1 ? l10n.tie : l10n.leader;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  winners.map((row) => '${row.email.split('@').first} · ${row.points}').join(', '),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerScoreCard extends StatelessWidget {
  const _PlayerScoreCard({
    required this.draft,
    required this.type,
    required this.total,
    required this.won,
    required this.enabled,
    required this.onChanged,
  });

  final _Draft draft;
  final GameType type;
  final int total;
  final bool won;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: draft.selected,
                  onChanged: enabled
                      ? (value) {
                          draft.selected = value ?? false;
                          onChanged();
                        }
                      : null,
                ),
                Expanded(
                  child: Text(
                    draft.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (draft.selected && won)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.emoji_events_rounded, color: theme.colorScheme.primary, size: 18),
                  ),
                if (draft.selected)
                  Text(
                    '$total',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            if (draft.selected && type == GameType.other)
              TextField(
                controller: draft.points,
                enabled: enabled,
                onTap: () => _selectAll(draft.points),
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
                decoration: InputDecoration(labelText: l10n.points),
                onChanged: (_) => onChanged(),
              ),
            if (draft.selected && type == GameType.sevenWonders)
              for (final category in WonderCategory.values) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: draft.categories[category],
                  enabled: enabled,
                  onTap: () => _selectAll(draft.categories[category]!),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
                  decoration: InputDecoration(
                    labelText: wonderCategoryLabel(l10n, category),
                    prefixIcon: Icon(
                      Icons.circle,
                      size: 14,
                      color: wonderCategoryColor(category),
                    ),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

void _selectAll(TextEditingController controller) {
  if (controller.text != '0') return;
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );
}

class _Draft {
  _Draft({
    required this.userId,
    required this.email,
    required this.selected,
  }) : points = TextEditingController(text: '0'),
       categories = {
         for (final category in WonderCategory.values)
           category: TextEditingController(text: '0'),
       };

  final String userId;
  final String email;
  bool selected;
  final TextEditingController points;
  final Map<WonderCategory, TextEditingController> categories;

  factory _Draft.fromMember(GameMember member, GameMatch? match, GameType type) {
    MatchScore? score;
    if (match != null) {
      for (final row in match.scores) {
        if (row.userId == member.userId) score = row;
      }
    }
    final draft = _Draft(
      userId: member.userId,
      email: member.email,
      selected: match == null || score != null,
    );
    if (score != null) {
      if (type == GameType.sevenWonders &&
          score.maravilla == 0 &&
          score.monedas == 0 &&
          score.rojo == 0 &&
          score.azul == 0 &&
          score.amarillo == 0 &&
          score.verde == 0 &&
          score.morado == 0 &&
          score.points != 0) {
        draft.categories[WonderCategory.maravilla]!.text = '${score.points}';
      } else if (type == GameType.sevenWonders) {
        draft.categories[WonderCategory.maravilla]!.text = _text(score.maravilla);
        draft.categories[WonderCategory.monedas]!.text = _text(score.monedas);
        draft.categories[WonderCategory.rojo]!.text = _text(score.rojo);
        draft.categories[WonderCategory.azul]!.text = _text(score.azul);
        draft.categories[WonderCategory.amarillo]!.text = _text(score.amarillo);
        draft.categories[WonderCategory.verde]!.text = _text(score.verde);
        draft.categories[WonderCategory.morado]!.text = _text(score.morado);
      } else {
        draft.points.text = '${score.points}';
      }
    }
    return draft;
  }

  static String _text(int value) => '$value';

  int pointsValue() => _parse(points.text);

  int value(WonderCategory category) => _parse(categories[category]!.text);

  bool isValid(GameType type) {
    if (type == GameType.other) return _ok(points.text);
    return WonderCategory.values.every((category) => _ok(categories[category]!.text));
  }

  bool _ok(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text == '-') return true;
    return int.tryParse(text) != null;
  }

  int _parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text == '-') return 0;
    return int.tryParse(text) ?? 0;
  }

  void dispose() {
    points.dispose();
    for (final controller in categories.values) {
      controller.dispose();
    }
  }
}
