import Charts
import FamilyCore
import SwiftUI

/// Standings, wins over time and records for a date range of the game's matches.
struct StatisticsSection: View {
  @Environment(AppModel.self) private var model
  @Environment(\.colorScheme) private var colorScheme
  let game: FamilyGame

  @State private var from: Date?
  @State private var to: Date?
  @State private var customRange = false
  @State private var selected: Int?

  private var bounds: ClosedRange<Date>? {
    let days = game.matches.map { day($0.playedAt) }
    guard let first = days.min(), let last = days.max() else { return nil }
    return first...last
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L("statistics")).font(.headline)
      Text(game.type == .sevenWonders ? L("scoringRuleSeven") : L("scoringRuleOther"))
        .font(.footnote).foregroundStyle(.secondary)
      if let bounds, game.matches.isEmpty == false {
        content(bounds: bounds)
      } else {
        Text(L("noStandings"))
      }
    }
    .onAppear(perform: sync)
    .onChange(of: game) { _, _ in sync() }
  }

  @ViewBuilder
  private func content(bounds: ClosedRange<Date>) -> some View {
    let from = self.from ?? bounds.lowerBound
    let to = self.to ?? bounds.upperBound
    HStack {
      DatePicker(L("dateFrom"), selection: fromBinding(default: bounds.lowerBound), in: bounds.lowerBound...to, displayedComponents: .date)
      DatePicker(L("dateTo"), selection: toBinding(default: bounds.upperBound), in: from...bounds.upperBound, displayedComponents: .date)
    }
    .font(.footnote)
    let matches = game.matches.filter { day($0.playedAt) >= from && day($0.playedAt) <= to }
    if matches.isEmpty {
      Text(L("noMatchesInRange"))
    } else {
      let members = game.members.map { ScoreLine(userId: $0.userId, email: $0.email, points: 0) }
      let chronological = matches.sorted { $0.playedAt != $1.playedAt ? $0.playedAt < $1.playedAt : $0.id < $1.id }
      let dated = chronological.map { DatedMatch(playedAt: $0.playedAt, scores: $0.scores.map(\.line)) }
      let standings = buildStandings(members: members, matches: dated.map(\.scores))
      let series = buildWinSeries(members: members, matches: dated)
      let highlights = buildRangeHighlights(members: members, matches: dated)
      let colors = winLineColors(dark: colorScheme == .dark)

      Text(L("winsOverTime")).font(.subheadline.weight(.bold))
      WinTrendChart(series: series, dates: chronological.map(\.playedAt), colors: colors, selected: $selected)
      Text(L("records")).font(.subheadline.weight(.bold))
      RecordGrid(highlights: highlights)
      Text(L("standings")).font(.subheadline.weight(.bold))
      ForEach(Array(standings.enumerated()), id: \.element.id) { index, standing in
        StandingRow(rank: index + 1, standing: standing, mine: standing.userId == model.userId)
      }
    }
  }

  private func day(_ date: Date) -> Date { Calendar.current.startOfDay(for: date) }

  private func fromBinding(default fallback: Date) -> Binding<Date> {
    Binding(
      get: { from ?? fallback },
      set: {
        from = day($0)
        customRange = true
      })
  }

  private func toBinding(default fallback: Date) -> Binding<Date> {
    Binding(
      get: { to ?? fallback },
      set: {
        to = day($0)
        customRange = true
      })
  }

  private func sync() {
    guard let bounds else {
      from = nil
      to = nil
      return
    }
    guard customRange, var lower = from, var upper = to else {
      from = bounds.lowerBound
      to = bounds.upperBound
      return
    }
    lower = max(lower, bounds.lowerBound)
    upper = min(upper, bounds.upperBound)
    if lower > upper { (lower, upper) = (bounds.lowerBound, bounds.upperBound) }
    from = lower
    to = upper
  }
}
