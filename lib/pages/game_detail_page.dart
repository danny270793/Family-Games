import 'package:family_games/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/di/injection.dart';
import '../core/theme/family_theme.dart';
import '../features/games/domain/entities/family_game.dart';
import '../features/games/presentation/cubit/game_cubit.dart';
import '../features/games/presentation/cubit/game_state.dart';
import 'statistics_page.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GameCubit>()..load(gameId),
      child: const _GameDetailView(),
    );
  }
}

class _GameDetailView extends StatelessWidget {
  const _GameDetailView();

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.watch<GameCubit>();
    final state = cubit.state;
    final game = cubit.game;
    final loading = state is GameLoading || state is GameInitial;
    return Scaffold(
      floatingActionButton: game == null
          ? null
          : FloatingActionButton.extended(
              onPressed: game.members.length < 2
                  ? () => _snack(context, l10n.noPlayers)
                  : () async {
                      final saved = await context.push<bool>(
                        '/games/${game.id}/matches/new',
                      );
                      if (saved == true) await cubit.load(game.id);
                    },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.newMatch),
            ),
      body: loading && game == null
          ? const Center(child: CircularProgressIndicator())
          : game == null
          ? Center(child: Text(l10n.unexpectedError))
          : CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  title: Text(game.name),
                  actions: [
                    IconButton(
                      tooltip: l10n.settings,
                      onPressed: () async {
                        await context.push('/games/${game.id}/settings');
                        await cubit.load(game.id);
                      },
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _HPad(child: _TypeChip(type: game.type)),
                      if (game.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _HPad(
                          child: Text(
                            game.description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  height: 1.4,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      GameStatisticsSection(game: game),
                      const SizedBox(height: 20),
                      _HPad(child: _SectionTitle(l10n.matches)),
                      const SizedBox(height: 12),
                      if (game.matches.isEmpty)
                        _HPad(child: Text(l10n.noMatches))
                      else
                        for (final match in game.matches)
                          _MatchTile(
                            match: match,
                            onTap: () async {
                              final saved = await context.push<bool>(
                                '/games/${game.id}/matches/${match.id}',
                              );
                              if (saved == true) await cubit.load(game.id);
                            },
                          ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match, required this.onTap});

  final GameMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(match.playedAt);
    final ranked = [...match.results]
      ..sort((a, b) => b.points.compareTo(a.points));
    final winners = ranked
        .where((row) => row.won)
        .map((row) => row.email)
        .toList();
    final winnerLabel = winners.length > 1
        ? '${l10n.tie}: ${winners.join(', ')}'
        : '${l10n.winner}: ${winners.join(', ')}';
    final scores = ranked
        .map((row) => '${row.email.split('@').first} ${row.points}')
        .join('  ·  ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    winnerLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scores,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _HPad extends StatelessWidget {
  const _HPad({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final GameType type;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wonders = type == GameType.sevenWonders;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: wonders ? scheme.primaryContainer : scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          gameTypeLabel(AppLocalizations.of(context), type),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: wonders
                ? scheme.onPrimaryContainer
                : scheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
