import 'package:family_games/core/di/injection.dart';
import 'package:family_games/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:family_games/l10n/app_localizations.dart';
import 'package:family_games/features/games/domain/entities/family_game.dart';
import 'package:family_games/features/games/domain/entities/standings.dart';
import 'package:family_games/widgets/win_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameStatisticsSection extends StatefulWidget {
  const GameStatisticsSection({super.key, required this.game});

  final FamilyGame game;

  @override
  State<GameStatisticsSection> createState() => _GameStatisticsSectionState();
}

class _GameStatisticsSectionState extends State<GameStatisticsSection> {
  DateTime? _from;
  DateTime? _to;
  bool _customRange = false;

  @override
  void initState() {
    super.initState();
    _sync(widget.game);
  }

  @override
  void didUpdateWidget(GameStatisticsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(widget.game);
  }

  void _sync(FamilyGame game) {
    final bounds = _matchBounds(game);
    if (bounds == null) {
      _from = null;
      _to = null;
      return;
    }
    if (!_customRange || _from == null || _to == null) {
      _from = bounds.$1;
      _to = bounds.$2;
      return;
    }
    var from = _from!;
    var to = _to!;
    if (from.isBefore(bounds.$1)) from = bounds.$1;
    if (to.isAfter(bounds.$2)) to = bounds.$2;
    if (from.isAfter(to)) {
      from = bounds.$1;
      to = bounds.$2;
    }
    _from = from;
    _to = to;
  }

  Future<void> _pickFrom() async {
    final bounds = _matchBounds(widget.game);
    final from = _from;
    final to = _to;
    if (bounds == null || from == null || to == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: bounds.$1,
      lastDate: to,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customRange = true;
      _from = _day(picked);
    });
  }

  Future<void> _pickTo() async {
    final bounds = _matchBounds(widget.game);
    final from = _from;
    final to = _to;
    if (bounds == null || from == null || to == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: to,
      firstDate: from,
      lastDate: bounds.$2,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customRange = true;
      _to = _day(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = widget.game;
    final from = _from;
    final to = _to;
    final matches = from == null || to == null
        ? const <GameMatch>[]
        : [
            for (final match in game.matches)
              if (!_day(match.playedAt).isBefore(from) &&
                  !_day(match.playedAt).isAfter(to))
                match,
          ];
    final members = [
      for (final member in game.members)
        ScoreLine(userId: member.userId, email: member.email, points: 0),
    ];
    final chronological = [...matches]
      ..sort((a, b) {
        final byDate = a.playedAt.compareTo(b.playedAt);
        if (byDate != 0) return byDate;
        return a.id.compareTo(b.id);
      });
    final dated = [
      for (final match in chronological)
        DatedMatch(
          playedAt: match.playedAt,
          scores: [for (final score in match.scores) score.line],
        ),
    ];
    final standings = buildStandings(
      members: members,
      matches: [for (final match in dated) match.scores],
    );
    final series = buildWinSeries(members: members, matches: dated);
    final highlights = buildRangeHighlights(members: members, matches: dated);
    final lineColors = Theme.of(context).brightness == Brightness.dark
        ? winLineColorsDark
        : winLineColors;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.statistics,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            game.type == GameType.sevenWonders
                ? l10n.scoringRuleSeven
                : l10n.scoringRuleOther,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (game.matches.isEmpty)
            Text(l10n.noStandings)
          else ...[
            Row(
              children: [
                Expanded(
                  child: _DateFilter(
                    label: l10n.dateFrom,
                    date: from!,
                    onTap: _pickFrom,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateFilter(
                    label: l10n.dateTo,
                    date: to!,
                    onTap: _pickTo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (matches.isEmpty)
              Text(l10n.noMatchesInRange)
            else ...[
              Text(
                l10n.winsOverTime,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              WinTrendChart(
                series: series,
                dates: [for (final match in chronological) match.playedAt],
                startLabel: l10n.chartStart,
                colors: lineColors,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < series.length; i++)
                    _LegendDot(
                      color: lineColors[i % lineColors.length],
                      label: series[i].email.split('@').first,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.records,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _RecordGrid(
                items: [
                  _Record(
                    label: l10n.longestWinStreak,
                    value: '${highlights.longestStreak}',
                    names: highlights.longestStreakEmails,
                  ),
                  _Record(
                    label: l10n.currentWinStreak,
                    value: '${highlights.currentStreak}',
                    names: highlights.currentStreakEmails,
                  ),
                  _Record(
                    label: l10n.highestScore,
                    value: highlights.highestScore == null
                        ? '—'
                        : '${highlights.highestScore}',
                    names: highlights.highestScoreEmails,
                  ),
                  _Record(
                    label: l10n.bestWinRate,
                    value: highlights.bestWinRatePercent == null
                        ? '—'
                        : '${highlights.bestWinRatePercent}%',
                    names: highlights.bestWinRateEmails,
                  ),
                  _Record(
                    label: l10n.longestLosingStreak,
                    value: '${highlights.longestLosingStreak}',
                    names: highlights.longestLosingStreakEmails,
                    negative: true,
                  ),
                  _Record(
                    label: l10n.currentLosingStreak,
                    value: '${highlights.currentLosingStreak}',
                    names: highlights.currentLosingStreakEmails,
                    negative: true,
                  ),
                  _Record(
                    label: l10n.lowestScore,
                    value: highlights.lowestScore == null
                        ? '—'
                        : '${highlights.lowestScore}',
                    names: highlights.lowestScoreEmails,
                    negative: true,
                  ),
                  _Record(
                    label: l10n.worstWinRate,
                    value: highlights.worstWinRatePercent == null
                        ? '—'
                        : '${highlights.worstWinRatePercent}%',
                    names: highlights.worstWinRateEmails,
                    negative: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.standings,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < standings.length; i++)
                _StandingRow(rank: i + 1, standing: standings[i]),
            ],
          ],
        ],
      ),
    );
  }
}

(DateTime, DateTime)? _matchBounds(FamilyGame game) {
  if (game.matches.isEmpty) return null;
  var first = _day(game.matches.first.playedAt);
  var last = first;
  for (final match in game.matches) {
    final day = _day(match.playedAt);
    if (day.isBefore(first)) first = day;
    if (day.isAfter(last)) last = day;
  }
  return (first, last);
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(date);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(formatted, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.rank, required this.standing});

  final int rank;
  final Standing standing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mine = standing.userId == getIt<GetCurrentUserUsecase>()()?.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: mine
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  mine ? '${standing.email} · ${l10n.you}' : standing.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _Count(label: l10n.wins, value: standing.wins),
              const SizedBox(width: 12),
              _Count(label: l10n.losses, value: standing.losses),
            ],
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _Record {
  const _Record({
    required this.label,
    required this.value,
    required this.names,
    this.negative = false,
  });

  final String label;
  final String value;
  final List<String> names;
  final bool negative;
}

class _RecordGrid extends StatelessWidget {
  const _RecordGrid({required this.items});

  final List<_Record> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _RecordCard(record: item),
              ),
          ],
        );
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final _Record record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = record.names
        .map((email) => email.split('@').first)
        .join(', ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              record.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: record.negative ? theme.colorScheme.error : null,
              ),
            ),
            if (names.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                names,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
