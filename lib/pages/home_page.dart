import 'package:family_games/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../core/theme/family_theme.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/games/domain/entities/family_game.dart';
import '../features/games/presentation/cubit/games_cubit.dart';
import '../features/games/presentation/cubit/games_state.dart';
import '../widgets/game_form_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GamesCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _create(BuildContext context) async {
    final cubit = context.read<GamesCubit>();
    await showGameFormSheet(context);
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<GamesCubit, GamesState>(
      builder: (context, state) => _buildScaffold(context, l10n, state),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n,
    GamesState state,
  ) {
    final cubit = context.read<GamesCubit>();
    final games = switch (state) {
      GamesLoaded(:final games) => games,
      GamesError(:final games) => games,
      _ => const <FamilyGame>[],
    };
    final loading = state is GamesLoading || state is GamesInitial;
    final failed = state is GamesError;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: cubit.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.medium(
              title: Text(l10n.appTitle),
              actions: [
                IconButton(
                  tooltip: l10n.settings,
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            if (loading && games.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (failed && games.isEmpty)
              SliverFillRemaining(
                child: _Message(
                  icon: Icons.cloud_off_rounded,
                  title: l10n.unexpectedError,
                  action: l10n.retry,
                  onAction: cubit.load,
                ),
              )
            else if (games.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _Message(
                  icon: Icons.sports_esports_rounded,
                  title: l10n.gamesEmptyTitle,
                  body: l10n.gamesEmptyBody,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverList.separated(
                  itemCount: games.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _GameCard(
                      game: game,
                      onTap: () async {
                        await context.push('/games/${game.id}');
                        await cubit.load();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newGame),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});

  final FamilyGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final userId = getIt<GetCurrentUserUsecase>()()?.id;
    final mine = game.standings.where((row) => row.userId == userId);
    final record = mine.isEmpty ? null : mine.first;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TypeChip(type: game.type),
                  const Spacer(),
                  Text(
                    l10n.playersCount(game.members.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(game.name, style: theme.textTheme.titleLarge),
              if (game.description.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    record == null
                        ? l10n.matchesCount(game.matches.length)
                        : '${l10n.wins} ${record.wins}  ·  ${l10n.losses} ${record.losses}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final GameType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final wonders = type == GameType.sevenWonders;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: wonders ? scheme.primaryContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        gameTypeLabel(l10n, type),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: wonders
              ? scheme.onPrimaryContainer
              : scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          if (action != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}
