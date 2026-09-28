class ScoreLine {
  const ScoreLine({
    required this.userId,
    required this.email,
    required this.points,
  });

  final String userId;
  final String email;
  final int points;
}

class PlayerResult {
  const PlayerResult({
    required this.userId,
    required this.email,
    required this.points,
    required this.won,
    required this.lost,
  });

  final String userId;
  final String email;
  final int points;
  final bool won;
  final bool lost;
}

class Standing {
  const Standing({
    required this.userId,
    required this.email,
    required this.wins,
    required this.losses,
    required this.points,
  });

  final String userId;
  final String email;
  final int wins;
  final int losses;
  final int points;
}

int sevenWondersTotal({
  required int maravilla,
  required int monedas,
  required int rojo,
  required int azul,
  required int amarillo,
  required int verde,
  required int morado,
}) {
  return maravilla + monedas + rojo + azul + amarillo + verde + morado;
}

/// Highest score wins. Every lower score is a loss. Players tied for the
/// highest score each win, and none of them take a loss.
List<PlayerResult> scoreResults(List<ScoreLine> lines) {
  if (lines.isEmpty) return const [];
  var maxPoints = lines.first.points;
  for (final line in lines) {
    if (line.points > maxPoints) maxPoints = line.points;
  }
  return [
    for (final line in lines)
      PlayerResult(
        userId: line.userId,
        email: line.email,
        points: line.points,
        won: line.points == maxPoints,
        lost: line.points < maxPoints,
      ),
  ];
}

List<Standing> buildStandings({
  required List<ScoreLine> members,
  required List<List<ScoreLine>> matches,
}) {
  final byUser = <String, _Tally>{
    for (final member in members)
      member.userId: _Tally(email: member.email),
  };

  for (final match in matches) {
    for (final result in scoreResults(match)) {
      final tally = byUser.putIfAbsent(
        result.userId,
        () => _Tally(email: result.email),
      );
      tally.points += result.points;
      if (result.won) tally.wins += 1;
      if (result.lost) tally.losses += 1;
    }
  }

  final standings = [
    for (final entry in byUser.entries)
      Standing(
        userId: entry.key,
        email: entry.value.email,
        wins: entry.value.wins,
        losses: entry.value.losses,
        points: entry.value.points,
      ),
  ];

  standings.sort((a, b) {
    final byWins = b.wins.compareTo(a.wins);
    if (byWins != 0) return byWins;
    final byLosses = a.losses.compareTo(b.losses);
    if (byLosses != 0) return byLosses;
    final byPoints = b.points.compareTo(a.points);
    if (byPoints != 0) return byPoints;
    return a.email.compareTo(b.email);
  });
  return standings;
}

class _Tally {
  _Tally({required this.email});

  final String email;
  int wins = 0;
  int losses = 0;
  int points = 0;
}

class DatedMatch {
  const DatedMatch({required this.playedAt, required this.scores});

  final DateTime playedAt;
  final List<ScoreLine> scores;
}

class WinSample {
  const WinSample({required this.cumulativeWins});

  final int cumulativeWins;
}

class WinSeries {
  const WinSeries({
    required this.userId,
    required this.email,
    required this.samples,
  });

  final String userId;
  final String email;

  /// Index 0 is everyone at zero, before the first match. Each later index
  /// is the running win total after that match.
  final List<WinSample> samples;
}

class RangeHighlights {
  const RangeHighlights({
    required this.longestStreak,
    required this.longestStreakEmails,
    required this.currentStreak,
    required this.currentStreakEmails,
    required this.highestScore,
    required this.highestScoreEmails,
    required this.bestWinRatePercent,
    required this.bestWinRateEmails,
    required this.longestLosingStreak,
    required this.longestLosingStreakEmails,
    required this.currentLosingStreak,
    required this.currentLosingStreakEmails,
    required this.lowestScore,
    required this.lowestScoreEmails,
    required this.worstWinRatePercent,
    required this.worstWinRateEmails,
  });

  final int longestStreak;
  final List<String> longestStreakEmails;
  final int currentStreak;
  final List<String> currentStreakEmails;
  final int? highestScore;
  final List<String> highestScoreEmails;
  final int? bestWinRatePercent;
  final List<String> bestWinRateEmails;
  final int longestLosingStreak;
  final List<String> longestLosingStreakEmails;
  final int currentLosingStreak;
  final List<String> currentLosingStreakEmails;
  final int? lowestScore;
  final List<String> lowestScoreEmails;
  final int? worstWinRatePercent;
  final List<String> worstWinRateEmails;
}

/// One line per player. A match the player sat out keeps their total flat.
/// A loss resets nothing here; it simply does not add a win.
List<WinSeries> buildWinSeries({
  required List<ScoreLine> members,
  required List<DatedMatch> matches,
}) {
  final totals = <String, int>{for (final member in members) member.userId: 0};
  final emails = <String, String>{
    for (final member in members) member.userId: member.email,
  };
  final samples = <String, List<WinSample>>{
    for (final member in members)
      member.userId: [const WinSample(cumulativeWins: 0)],
  };

  for (final match in matches) {
    for (final result in scoreResults(match.scores)) {
      emails.putIfAbsent(result.userId, () => result.email);
      if (!samples.containsKey(result.userId)) {
        final prior = samples.isEmpty ? 1 : samples.values.first.length;
        samples[result.userId] = [
          for (var i = 0; i < prior; i++) const WinSample(cumulativeWins: 0),
        ];
        totals[result.userId] = 0;
      }
      totals[result.userId] = (totals[result.userId] ?? 0) + (result.won ? 1 : 0);
    }
    for (final userId in samples.keys) {
      samples[userId]!.add(WinSample(cumulativeWins: totals[userId] ?? 0));
    }
  }

  final series = [
    for (final entry in samples.entries)
      WinSeries(
        userId: entry.key,
        email: emails[entry.key] ?? '',
        samples: entry.value,
      ),
  ]..sort((a, b) => a.email.compareTo(b.email));
  return series;
}

/// Streaks count matches a player actually played. Sitting one out does not
/// break a run. A tie for first counts as a victory.
RangeHighlights buildRangeHighlights({
  required List<ScoreLine> members,
  required List<DatedMatch> matches,
}) {
  final emails = <String, String>{
    for (final member in members) member.userId: member.email,
  };
  final best = <String, int>{};
  final current = <String, int>{};
  final longestLoss = <String, int>{};
  final currentLoss = <String, int>{};
  final played = <String, int>{};
  final wins = <String, int>{};
  int? highScore;
  final highScoreEmails = <String>{};
  int? lowScore;
  final lowScoreEmails = <String>{};

  for (final match in matches) {
    final results = scoreResults(match.scores);
    int? matchHigh;
    int? matchLow;
    for (final result in results) {
      if (matchHigh == null || result.points > matchHigh) matchHigh = result.points;
      if (matchLow == null || result.points < matchLow) matchLow = result.points;
    }
    if (matchHigh != null && (highScore == null || matchHigh > highScore)) {
      highScore = matchHigh;
      highScoreEmails
        ..clear()
        ..addAll(
          results.where((row) => row.points == matchHigh).map((row) => row.email),
        );
    } else if (matchHigh != null && matchHigh == highScore) {
      highScoreEmails.addAll(
        results.where((row) => row.points == matchHigh).map((row) => row.email),
      );
    }
    if (matchLow != null && (lowScore == null || matchLow < lowScore)) {
      lowScore = matchLow;
      lowScoreEmails
        ..clear()
        ..addAll(
          results.where((row) => row.points == matchLow).map((row) => row.email),
        );
    } else if (matchLow != null && matchLow == lowScore) {
      lowScoreEmails.addAll(
        results.where((row) => row.points == matchLow).map((row) => row.email),
      );
    }

    for (final result in results) {
      emails.putIfAbsent(result.userId, () => result.email);
      played[result.userId] = (played[result.userId] ?? 0) + 1;
      final run = result.won ? (current[result.userId] ?? 0) + 1 : 0;
      current[result.userId] = run;
      final losses = result.lost ? (currentLoss[result.userId] ?? 0) + 1 : 0;
      currentLoss[result.userId] = losses;
      if (result.won) wins[result.userId] = (wins[result.userId] ?? 0) + 1;
      if (run > (best[result.userId] ?? 0)) best[result.userId] = run;
      if (losses > (longestLoss[result.userId] ?? 0)) {
        longestLoss[result.userId] = losses;
      }
    }
  }

  final longest = _leaders(best, emails);
  final active = _leaders(current, emails);
  final longestLosses = _leaders(longestLoss, emails);
  final activeLosses = _leaders(currentLoss, emails);
  int? bestRate;
  int? worstRate;
  final rateEmails = <String>[];
  final worstEmails = <String>[];
  for (final entry in played.entries) {
    final count = entry.value;
    if (count == 0) continue;
    final rate = (((wins[entry.key] ?? 0) * 100) / count).round();
    final email = emails[entry.key] ?? '';
    if (bestRate == null || rate > bestRate) {
      bestRate = rate;
      rateEmails
        ..clear()
        ..add(email);
    } else if (rate == bestRate) {
      rateEmails.add(email);
    }
    if (worstRate == null || rate < worstRate) {
      worstRate = rate;
      worstEmails
        ..clear()
        ..add(email);
    } else if (rate == worstRate) {
      worstEmails.add(email);
    }
  }
  rateEmails.sort();
  worstEmails.sort();

  return RangeHighlights(
    longestStreak: longest.$1,
    longestStreakEmails: longest.$2,
    currentStreak: active.$1,
    currentStreakEmails: active.$2,
    highestScore: highScore,
    highestScoreEmails: highScoreEmails.toList()..sort(),
    bestWinRatePercent: bestRate,
    bestWinRateEmails: rateEmails,
    longestLosingStreak: longestLosses.$1,
    longestLosingStreakEmails: longestLosses.$2,
    currentLosingStreak: activeLosses.$1,
    currentLosingStreakEmails: activeLosses.$2,
    lowestScore: lowScore,
    lowestScoreEmails: lowScoreEmails.toList()..sort(),
    worstWinRatePercent: worstRate,
    worstWinRateEmails: worstEmails,
  );
}

(int, List<String>) _leaders(Map<String, int> values, Map<String, String> emails) {
  var best = 0;
  final names = <String>[];
  for (final entry in values.entries) {
    if (entry.value > best) {
      best = entry.value;
      names
        ..clear()
        ..add(emails[entry.key] ?? '');
    } else if (entry.value == best && best > 0) {
      names.add(emails[entry.key] ?? '');
    }
  }
  names.sort();
  return (best, names);
}
