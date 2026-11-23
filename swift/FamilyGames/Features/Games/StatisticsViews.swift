import Charts
import FamilyCore
import SwiftUI

struct WinTrendChart: View {
  let series: [WinSeries]
  /// Dates of the matches in order; sample `i` (1-based) is the total after `dates[i - 1]`.
  let dates: [Date]
  let colors: [Color]
  @Binding var selected: Int?

  private struct Point: Identifiable {
    let id: String
    let name: String
    let index: Int
    let wins: Int
  }

  private var points: [Point] {
    series.flatMap { row in
      row.cumulativeWins.enumerated().map {
        Point(id: "\(row.userId)-\($0.offset)", name: shortName(row.email), index: $0.offset, wins: $0.element)
      }
    }
  }

  var body: some View {
    guard let count = series.first?.cumulativeWins.count, count >= 2 else { return AnyView(EmptyView()) }
    let current = min(max(selected ?? count - 1, 0), count - 1)
    let names = series.map { shortName($0.email) }
    return AnyView(
      VStack(alignment: .leading, spacing: 8) {
        Chart {
          ForEach(points) { point in
            LineMark(x: .value("Match", point.index), y: .value("Wins", point.wins))
              .foregroundStyle(by: .value("Player", point.name))
              .interpolationMethod(.monotone)
          }
          RuleMark(x: .value("Match", current)).foregroundStyle(.secondary.opacity(0.4))
        }
        .chartForegroundStyleScale(domain: names, range: names.indices.map { colors[$0 % colors.count] })
        .chartLegend(.hidden)
        .chartXSelection(value: $selected)
        .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) }
        .frame(height: 200)
        Text(current == 0 ? L("chartStart") : dates[current - 1].formatted(date: .abbreviated, time: .omitted))
          .font(.subheadline.weight(.medium))
        Text(series.map { "\(shortName($0.email)) \($0.cumulativeWins[current])" }.joined(separator: "  ·  "))
          .font(.footnote).foregroundStyle(.secondary)
        FlowLegend(items: names.enumerated().map { ($0.element, colors[$0.offset % colors.count]) })
      }
    )
  }
}

/// Colored dots with player names that wrap onto several lines.
private struct FlowLegend: View {
  let items: [(String, Color)]

  var body: some View {
    FlowLayout(spacing: 12) {
      ForEach(Array(items.enumerated()), id: \.offset) { _, item in
        HStack(spacing: 6) {
          Circle().fill(item.1).frame(width: 10, height: 10)
          Text(item.0).font(.subheadline)
        }
      }
    }
  }
}

struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    layout(in: proposal.width ?? .infinity, subviews: subviews).size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = layout(in: bounds.width, subviews: subviews)
    for (index, origin) in result.origins.enumerated() {
      subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
    }
  }

  private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
    var origins: [CGPoint] = []
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0
    var maxX: CGFloat = 0
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if x > 0, x + size.width > width {
        x = 0
        y += rowHeight + spacing
        rowHeight = 0
      }
      origins.append(CGPoint(x: x, y: y))
      x += size.width + spacing
      rowHeight = max(rowHeight, size.height)
      maxX = max(maxX, x - spacing)
    }
    return (CGSize(width: maxX, height: y + rowHeight), origins)
  }
}

struct RecordGrid: View {
  let highlights: RangeHighlights

  private struct Record: Identifiable {
    let label: String
    let value: String
    let names: [String]
    var negative = false
    var id: String { label }
  }

  private var records: [Record] {
    let h = highlights
    func score(_ value: Int?) -> String { value.map(String.init) ?? "—" }
    func rate(_ value: Int?) -> String { value.map { "\($0)%" } ?? "—" }
    return [
      Record(label: L("longestWinStreak"), value: "\(h.longestStreak)", names: h.longestStreakEmails),
      Record(label: L("currentWinStreak"), value: "\(h.currentStreak)", names: h.currentStreakEmails),
      Record(label: L("highestScore"), value: score(h.highestScore), names: h.highestScoreEmails),
      Record(label: L("bestWinRate"), value: rate(h.bestWinRatePercent), names: h.bestWinRateEmails),
      Record(label: L("longestLosingStreak"), value: "\(h.longestLosingStreak)", names: h.longestLosingStreakEmails, negative: true),
      Record(label: L("currentLosingStreak"), value: "\(h.currentLosingStreak)", names: h.currentLosingStreakEmails, negative: true),
      Record(label: L("lowestScore"), value: score(h.lowestScore), names: h.lowestScoreEmails, negative: true),
      Record(label: L("worstWinRate"), value: rate(h.worstWinRatePercent), names: h.worstWinRateEmails, negative: true),
    ]
  }

  var body: some View {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
      ForEach(records) { record in
        VStack(alignment: .leading, spacing: 3) {
          Text(record.label).font(.caption).foregroundStyle(.secondary)
          Text(record.value).font(.title2.bold()).foregroundStyle(record.negative ? Color.red : Color.primary)
          if !record.names.isEmpty {
            Text(record.names.map(shortName).joined(separator: ", ")).font(.footnote).lineLimit(2)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 14))
      }
    }
  }
}

struct StandingRow: View {
  let rank: Int
  let standing: Standing
  let mine: Bool

  var body: some View {
    HStack(spacing: 12) {
      Text("\(rank)").font(.headline).frame(width: 24, alignment: .leading)
      Text(mine ? "\(standing.email) · \(L("you"))" : standing.email).lineLimit(1)
      Spacer()
      count(L("wins"), standing.wins)
      count(L("losses"), standing.losses)
    }
    .padding(12)
    .background(mine ? Color.accentColor.opacity(0.14) : Color.secondary.opacity(0.08), in: .rect(cornerRadius: 14))
  }

  private func count(_ label: String, _ value: Int) -> some View {
    VStack {
      Text("\(value)").font(.headline).monospacedDigit()
      Text(label).font(.caption2).foregroundStyle(.secondary)
    }
  }
}
