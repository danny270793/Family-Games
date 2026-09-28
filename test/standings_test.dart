import 'package:family_games/logic/standings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('highest score wins and everyone else loses', () {
    final results = scoreResults(const [
      ScoreLine(userId: 'a', email: 'a@x.com', points: 10),
      ScoreLine(userId: 'b', email: 'b@x.com', points: 8),
      ScoreLine(userId: 'c', email: 'c@x.com', points: 4),
    ]);

    expect(results.singleWhere((row) => row.userId == 'a').won, isTrue);
    expect(results.singleWhere((row) => row.userId == 'a').lost, isFalse);
    expect(results.where((row) => row.lost).length, 2);
  });

  test('a tie for first is a win for each tied player', () {
    final results = scoreResults(const [
      ScoreLine(userId: 'a', email: 'a@x.com', points: 5),
      ScoreLine(userId: 'b', email: 'b@x.com', points: 5),
      ScoreLine(userId: 'c', email: 'c@x.com', points: 1),
    ]);

    expect(results.where((row) => row.won).map((row) => row.userId), ['a', 'b']);
    expect(results.singleWhere((row) => row.userId == 'c').lost, isTrue);
  });

  test('seven wonders categories add up', () {
    expect(
      sevenWondersTotal(
        maravilla: 10,
        monedas: 3,
        rojo: 7,
        azul: 4,
        amarillo: 2,
        verde: 6,
        morado: 5,
      ),
      37,
    );
  });

  test('standings rank by wins, then fewer losses', () {
    final standings = buildStandings(
      members: const [
        ScoreLine(userId: 'a', email: 'a@x.com', points: 0),
        ScoreLine(userId: 'b', email: 'b@x.com', points: 0),
      ],
      matches: [
        [
          ScoreLine(userId: 'a', email: 'a@x.com', points: 10),
          ScoreLine(userId: 'b', email: 'b@x.com', points: 4),
        ],
        [
          ScoreLine(userId: 'a', email: 'a@x.com', points: 3),
          ScoreLine(userId: 'b', email: 'b@x.com', points: 9),
        ],
      ],
    );

    expect(standings.map((row) => row.userId), ['a', 'b']);
    expect(standings.first.wins, 1);
    expect(standings.first.losses, 1);
    expect(standings.first.points, 13);
  });

  test('win lines climb only when that player wins', () {
    final series = buildWinSeries(
      members: const [
        ScoreLine(userId: 'a', email: 'a@x.com', points: 0),
        ScoreLine(userId: 'b', email: 'b@x.com', points: 0),
      ],
      matches: [
        DatedMatch(
          playedAt: DateTime.utc(2026, 1, 1),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 10),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 4),
          ],
        ),
        DatedMatch(
          playedAt: DateTime.utc(2026, 1, 8),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 3),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 9),
          ],
        ),
      ],
    );

    final a = series.singleWhere((row) => row.userId == 'a').samples;
    final b = series.singleWhere((row) => row.userId == 'b').samples;
    expect(a.map((sample) => sample.cumulativeWins), [0, 1, 1]);
    expect(b.map((sample) => sample.cumulativeWins), [0, 0, 1]);
  });

  test('a missed match does not break a win streak', () {
    final highlights = buildRangeHighlights(
      members: const [
        ScoreLine(userId: 'a', email: 'a@x.com', points: 0),
        ScoreLine(userId: 'b', email: 'b@x.com', points: 0),
      ],
      matches: [
        DatedMatch(
          playedAt: DateTime.utc(2026, 1, 1),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 8),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 2),
          ],
        ),
        DatedMatch(
          playedAt: DateTime.utc(2026, 1, 2),
          scores: [
            ScoreLine(userId: 'b', email: 'b@x.com', points: 5),
            ScoreLine(userId: 'c', email: 'c@x.com', points: 1),
          ],
        ),
        DatedMatch(
          playedAt: DateTime.utc(2026, 1, 3),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 6),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 4),
          ],
        ),
      ],
    );

    expect(highlights.longestStreak, 2);
    expect(highlights.longestStreakEmails, ['a@x.com']);
    expect(highlights.currentStreak, 2);
    expect(highlights.highestScore, 8);
    expect(highlights.bestWinRatePercent, 100);
    expect(highlights.bestWinRateEmails, ['a@x.com']);
    expect(highlights.longestLosingStreak, 1);
    expect(highlights.lowestScore, 1);
    expect(highlights.lowestScoreEmails, ['c@x.com']);
    expect(highlights.worstWinRatePercent, 0);
    expect(highlights.worstWinRateEmails, ['c@x.com']);
  });

  test('a loss ends the current streak but keeps the longest', () {
    final highlights = buildRangeHighlights(
      members: const [ScoreLine(userId: 'a', email: 'a@x.com', points: 0)],
      matches: [
        DatedMatch(
          playedAt: DateTime.utc(2026, 2, 1),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 4),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 1),
          ],
        ),
        DatedMatch(
          playedAt: DateTime.utc(2026, 2, 2),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 4),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 1),
          ],
        ),
        DatedMatch(
          playedAt: DateTime.utc(2026, 2, 3),
          scores: [
            ScoreLine(userId: 'a', email: 'a@x.com', points: 1),
            ScoreLine(userId: 'b', email: 'b@x.com', points: 9),
          ],
        ),
      ],
    );

    expect(highlights.longestStreak, 2);
    expect(highlights.currentStreak, 1);
    expect(highlights.currentStreakEmails, ['b@x.com']);
    expect(highlights.longestLosingStreak, 2);
    expect(highlights.longestLosingStreakEmails, ['b@x.com']);
    expect(highlights.currentLosingStreak, 1);
    expect(highlights.currentLosingStreakEmails, ['a@x.com']);
    expect(highlights.lowestScore, 1);
    expect(highlights.worstWinRatePercent, 33);
    expect(highlights.worstWinRateEmails, ['b@x.com']);
  });
}
