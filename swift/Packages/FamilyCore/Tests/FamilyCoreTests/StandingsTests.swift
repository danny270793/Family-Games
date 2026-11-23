import FamilyCore
import Foundation
import Testing

private func line(_ id: String, _ points: Int) -> ScoreLine {
  ScoreLine(userId: id, email: "\(id)@x.com", points: points)
}

private func day(_ d: Int) -> Date { Date(timeIntervalSince1970: Double(d) * 86400) }

@Test func highestScoreWinsAndEveryoneElseLoses() {
  let results = scoreResults([line("a", 10), line("b", 8), line("c", 4)])
  #expect(results.first { $0.userId == "a" }?.won == true)
  #expect(results.first { $0.userId == "a" }?.lost == false)
  #expect(results.filter(\.lost).count == 2)
}

@Test func aTieForFirstIsAWinForEachTiedPlayer() {
  let results = scoreResults([line("a", 5), line("b", 5), line("c", 1)])
  #expect(results.filter(\.won).map(\.userId) == ["a", "b"])
  #expect(results.first { $0.userId == "c" }?.lost == true)
}

@Test func sevenWondersCategoriesAddUp() {
  #expect(
    sevenWondersTotal(maravilla: 10, monedas: 3, rojo: 7, azul: 4, amarillo: 2, verde: 6, morado: 5) == 37)
}

@Test func standingsRankByWinsThenFewerLosses() {
  let standings = buildStandings(
    members: [line("a", 0), line("b", 0)],
    matches: [[line("a", 10), line("b", 4)], [line("a", 3), line("b", 9)]])
  #expect(standings.map(\.userId) == ["a", "b"])
  #expect(standings.first?.wins == 1)
  #expect(standings.first?.losses == 1)
  #expect(standings.first?.points == 13)
}

@Test func winLinesClimbOnlyWhenThatPlayerWins() {
  let series = buildWinSeries(
    members: [line("a", 0), line("b", 0)],
    matches: [
      DatedMatch(playedAt: day(1), scores: [line("a", 10), line("b", 4)]),
      DatedMatch(playedAt: day(8), scores: [line("a", 3), line("b", 9)]),
    ])
  #expect(series.first { $0.userId == "a" }?.cumulativeWins == [0, 1, 1])
  #expect(series.first { $0.userId == "b" }?.cumulativeWins == [0, 0, 1])
}

@Test func aMissedMatchDoesNotBreakAWinStreak() {
  let highlights = buildRangeHighlights(
    members: [line("a", 0), line("b", 0)],
    matches: [
      DatedMatch(playedAt: day(1), scores: [line("a", 8), line("b", 2)]),
      DatedMatch(playedAt: day(2), scores: [line("b", 5), line("c", 1)]),
      DatedMatch(playedAt: day(3), scores: [line("a", 6), line("b", 4)]),
    ])
  #expect(highlights.longestStreak == 2)
  #expect(highlights.longestStreakEmails == ["a@x.com"])
  #expect(highlights.currentStreak == 2)
  #expect(highlights.highestScore == 8)
  #expect(highlights.bestWinRatePercent == 100)
  #expect(highlights.bestWinRateEmails == ["a@x.com"])
  #expect(highlights.longestLosingStreak == 1)
  #expect(highlights.lowestScore == 1)
  #expect(highlights.lowestScoreEmails == ["c@x.com"])
  #expect(highlights.worstWinRatePercent == 0)
  #expect(highlights.worstWinRateEmails == ["c@x.com"])
}

@Test func aLossEndsTheCurrentStreakButKeepsTheLongest() {
  let highlights = buildRangeHighlights(
    members: [line("a", 0)],
    matches: [
      DatedMatch(playedAt: day(1), scores: [line("a", 4), line("b", 1)]),
      DatedMatch(playedAt: day(2), scores: [line("a", 4), line("b", 1)]),
      DatedMatch(playedAt: day(3), scores: [line("a", 1), line("b", 9)]),
    ])
  #expect(highlights.longestStreak == 2)
  #expect(highlights.currentStreak == 1)
  #expect(highlights.currentStreakEmails == ["b@x.com"])
  #expect(highlights.longestLosingStreak == 2)
  #expect(highlights.longestLosingStreakEmails == ["b@x.com"])
  #expect(highlights.currentLosingStreak == 1)
  #expect(highlights.currentLosingStreakEmails == ["a@x.com"])
  #expect(highlights.lowestScore == 1)
  #expect(highlights.worstWinRatePercent == 33)
  #expect(highlights.worstWinRateEmails == ["b@x.com"])
}

@Test func wallClockRoundTrips() {
  let date = parseWallClock("2026-03-11T19:30:00")
  #expect(date != nil)
  #expect(formatWallClock(date!) == "2026-03-11T19:30:00")
  #expect(parseWallClock("2026-03-11 19:30:00.123") != nil)
}

@Test func decodesAGameWithMembersAndMatches() throws {
  let json = """
    [{"id":"g1","name":"7W","type":"seven_wonders","description":null,"created_by":"u1",
      "fg_game_members":[{"id":"m2","user_id":"u2","email":"b@x.com"},{"id":"m1","user_id":"u1","email":"a@x.com"}],
      "fg_matches":[
        {"id":"x1","played_at":"2026-03-10T20:00:00","fg_match_scores":[
          {"user_id":"u1","email":"a@x.com","points":30,"maravilla":10,"monedas":3,"rojo":5,"azul":4,"amarillo":3,"verde":3,"morado":2},
          {"user_id":"u2","email":"b@x.com","points":25.0,"maravilla":0,"monedas":0,"rojo":0,"azul":0,"amarillo":0,"verde":0,"morado":0}]},
        {"id":"x2","played_at":"2026-03-12T20:00:00","fg_match_scores":[]}]}]
    """
  let games = try FamilyGame.decodeList(Data(json.utf8))
  let game = try #require(games.first)
  #expect(game.type == .sevenWonders)
  #expect(game.description == "")
  #expect(game.members.map(\.email) == ["a@x.com", "b@x.com"])
  #expect(game.matches.map(\.id) == ["x2", "x1"])
  #expect(game.matches[1].scores[1].points == 25)
  #expect(game.matches[1].scores[1].hasNoCategories)
  #expect(game.standings.first?.userId == "u1")
}
