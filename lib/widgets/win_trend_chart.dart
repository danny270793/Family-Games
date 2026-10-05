import 'package:family_games/features/games/domain/entities/standings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

const winLineColors = <Color>[
  Color(0xFF7A3142),
  Color(0xFF2A6F4E),
  Color(0xFF315F8C),
  Color(0xFFC47B2B),
  Color(0xFF6B4C9A),
  Color(0xFFB5524A),
  Color(0xFF3E7C8A),
  Color(0xFF8A5A2B),
];

const winLineColorsDark = <Color>[
  Color(0xFFE7A0AE),
  Color(0xFF7DCEA0),
  Color(0xFF8EB4E0),
  Color(0xFFE2B15A),
  Color(0xFFC4A6E8),
  Color(0xFFF0A197),
  Color(0xFF8FD0D6),
  Color(0xFFE0B48A),
];

class WinTrendChart extends StatefulWidget {
  const WinTrendChart({
    super.key,
    required this.series,
    required this.dates,
    required this.startLabel,
    required this.colors,
  });

  final List<WinSeries> series;
  final List<DateTime> dates;
  final String startLabel;
  final List<Color> colors;

  @override
  State<WinTrendChart> createState() => _WinTrendChartState();
}

class _WinTrendChartState extends State<WinTrendChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = widget.series;
    if (series.isEmpty || series.first.samples.length < 2) {
      return const SizedBox.shrink();
    }
    final count = series.first.samples.length;
    final selected = (_selected ?? count - 1).clamp(0, count - 1);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = selected == 0
        ? widget.startLabel
        : DateFormat.yMMMd(locale).format(widget.dates[selected - 1]);
    final caption = series
        .map((row) {
          final wins = row.samples[selected].cumulativeWins;
          final name = row.email.split('@').first;
          return '$name $wins';
        })
        .join('  ·  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) => _select(
                  details.localPosition.dx,
                  constraints.maxWidth,
                  count,
                ),
                onHorizontalDragUpdate: (details) => _select(
                  details.localPosition.dx,
                  constraints.maxWidth,
                  count,
                ),
                child: CustomPaint(
                  painter: _WinTrendPainter(
                    series: series,
                    colors: widget.colors,
                    selected: selected,
                    labelStyle: theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    gridColor: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.7,
                    ),
                    guideColor: theme.colorScheme.primary.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(dateLabel, style: theme.textTheme.labelLarge),
        Text(
          caption,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  void _select(double dx, double width, int count) {
    const left = 28.0;
    const right = 8.0;
    final plot = (width - left - right).clamp(1.0, double.infinity);
    final t = ((dx - left) / plot).clamp(0.0, 1.0);
    final index = count == 1 ? 0 : (t * (count - 1)).round();
    setState(() => _selected = index);
  }
}

class _WinTrendPainter extends CustomPainter {
  _WinTrendPainter({
    required this.series,
    required this.colors,
    required this.selected,
    required this.labelStyle,
    required this.gridColor,
    required this.guideColor,
  });

  final List<WinSeries> series;
  final List<Color> colors;
  final int selected;
  final TextStyle labelStyle;
  final Color gridColor;
  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const right = 8.0;
    const top = 8.0;
    const bottom = 4.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final count = series.first.samples.length;
    var maxWins = 1;
    for (final row in series) {
      for (final sample in row.samples) {
        if (sample.cumulativeWins > maxWins) maxWins = sample.cumulativeWins;
      }
    }

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var tick = 0; tick <= maxWins; tick++) {
      if (maxWins > 6 &&
          tick % ((maxWins / 4).ceil()) != 0 &&
          tick != maxWins) {
        continue;
      }
      final y = plot.bottom - (tick / maxWins) * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final painter = TextPainter(
        text: TextSpan(text: '$tick', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: left);
      painter.paint(canvas, Offset(0, y - painter.height / 2));
    }

    double xAt(int index) {
      if (count == 1) return plot.left;
      return plot.left + plot.width * index / (count - 1);
    }

    final guide = Paint()
      ..color = guideColor
      ..strokeWidth = 1.5;
    final guideX = xAt(selected);
    canvas.drawLine(
      Offset(guideX, plot.top),
      Offset(guideX, plot.bottom),
      guide,
    );

    for (var i = 0; i < series.length; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      final samples = series[i].samples;
      for (var index = 0; index < samples.length; index++) {
        final point = Offset(
          xAt(index),
          plot.bottom - (samples[index].cumulativeWins / maxWins) * plot.height,
        );
        if (index == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
      final dot = Paint()..color = color;
      for (var index = 0; index < samples.length; index++) {
        canvas.drawCircle(
          Offset(
            xAt(index),
            plot.bottom -
                (samples[index].cumulativeWins / maxWins) * plot.height,
          ),
          index == selected ? 4.5 : 3,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WinTrendPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.selected != selected ||
        oldDelegate.colors != colors ||
        oldDelegate.gridColor != gridColor;
  }
}
