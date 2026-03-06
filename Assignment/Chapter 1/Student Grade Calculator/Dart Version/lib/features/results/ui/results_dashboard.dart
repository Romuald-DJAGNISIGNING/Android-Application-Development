import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chart_dataset.dart';
import '../../../core/models/grade_config.dart';
import '../../../core/models/grade_result.dart';
import '../../../core/models/processing_summary.dart';
import '../../../core/models/validation_issue.dart';
import '../../../core/providers/grade_calculator_controller.dart';

class ResultsDashboard extends ConsumerWidget {
  const ResultsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);
    final report = state.report;
    if (report == null) {
      return const SizedBox.shrink();
    }

    return Column(
      key: ValueKey(report.summary.totalRows),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RevealPanel(child: _SummaryStrip(summary: report.summary)),
        const SizedBox(height: 18),
        _RevealPanel(child: _ChartPanel(chart: state.chart)),
        const SizedBox(height: 18),
        _RevealPanel(child: _PreviewPanel(results: report.results)),
        const SizedBox(height: 18),
        _RevealPanel(child: _IssuePanel(issues: report.issues)),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final ProcessingSummary summary;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('0.00');
    final cards = [
      _MetricData(
        label: 'Rows Processed',
        value: summary.totalRows.toString(),
        note: 'Full class list ingested',
        accent: const Color(0xFF18314F),
        icon: Icons.layers_rounded,
      ),
      _MetricData(
        label: 'Average Score',
        value: fmt.format(summary.average),
        note: 'Overall class trend',
        accent: const Color(0xFF24706A),
        icon: Icons.show_chart_rounded,
      ),
      _MetricData(
        label: 'Median Score',
        value: fmt.format(summary.median),
        note: 'Center of the distribution',
        accent: const Color(0xFFB8743C),
        icon: Icons.balance_rounded,
      ),
      _MetricData(
        label: 'Pass Rate',
        value: '${fmt.format(summary.passRate)}%',
        note: 'Students at C and above',
        accent: const Color(0xFF72408C),
        icon: Icons.workspace_premium_rounded,
      ),
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: cards
          .map((card) => _MetricCard(data: card))
          .toList(growable: false),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.note,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final String note;
  final Color accent;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [data.accent, Color.lerp(data.accent, Colors.white, 0.18)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: data.accent.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: Colors.white),
              ),
              const Spacer(),
              const Icon(Icons.arrow_outward_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            data.label,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 30,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.note,
            style: const TextStyle(color: Color(0xD9FFFFFF), height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.chart});

  final ChartDataset chart;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Grade Distribution',
      eyebrow: 'Visual Breakdown',
      subtitle:
          'A cleaner read of the class profile with count bars and a presentation-ready pie chart.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          if (wide) {
            return SizedBox(
              height: 330,
              child: Row(
                children: [
                  Expanded(child: _Pie(chart: chart)),
                  const SizedBox(width: 18),
                  Expanded(child: _Legend(chart: chart)),
                ],
              ),
            );
          }

          return Column(
            children: [
              SizedBox(height: 280, child: _Pie(chart: chart)),
              const SizedBox(height: 16),
              SizedBox(height: 210, child: _Legend(chart: chart)),
            ],
          );
        },
      ),
    );
  }
}

class _Pie extends StatelessWidget {
  const _Pie({required this.chart});

  final ChartDataset chart;

  @override
  Widget build(BuildContext context) {
    if (chart.points.isEmpty) {
      return const Center(child: Text('No chart data yet.'));
    }

    const colors = <Color>[
      Color(0xFF24706A),
      Color(0xFF18314F),
      Color(0xFFB8743C),
      Color(0xFF72408C),
      Color(0xFF7B8BA4),
      Color(0xFFB5483C),
      Color(0xFF2E5D91),
      Color(0xFF957049),
      Color(0xFF202635),
    ];

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.82, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFBF7EF), Color(0xFFF4EEE3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 54,
            centerSpaceColor: const Color(0xFFF6F1E8),
            sections: chart.points
                .asMap()
                .entries
                .map((entry) {
                  final point = entry.value;
                  return PieChartSectionData(
                    title: point.label,
                    value: point.count.toDouble(),
                    radius: 88,
                    color: colors[entry.key % colors.length],
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.chart});

  final ChartDataset chart;

  @override
  Widget build(BuildContext context) {
    if (chart.points.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = chart.points.fold<int>(0, (sum, point) => sum + point.count);
    return ListView.separated(
      itemCount: chart.points.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final point = chart.points[index];
        final accent = _gradeTone(point.label);
        final ratio = total == 0 ? 0.0 : point.count / total;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEAE1D4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Grade ${point.label}',
                    style: const TextStyle(
                      color: Color(0xFF1C2332),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${point.count} students',
                    style: const TextStyle(
                      color: Color(0xFF5A6474),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFF1E8DA),
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(ratio * 100).toStringAsFixed(1)}% of the processed class',
                style: const TextStyle(color: Color(0xFF697386)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.results});

  final List<GradeResult> results;

  @override
  Widget build(BuildContext context) {
    final preview = results.take(15).toList(growable: false);
    const widths = [72.0, 180.0, 150.0, 100.0, 92.0, 88.0, 170.0];
    const headers = [
      'Row',
      'Name',
      'Matricule',
      'Score',
      'Letter',
      'Pass',
      'Source',
    ];

    return _Panel(
      title: 'Processed Rows',
      eyebrow: 'Curated Preview',
      subtitle:
          'A refined preview of the first rows so you can inspect the grading output before export.',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TableRowShell(
              background: const Color(0xFF18314F),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              children: List.generate(
                headers.length,
                (index) => _TableCell(
                  width: widths[index],
                  child: Text(
                    headers[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            ...preview.asMap().entries.map((entry) {
              final index = entry.key;
              final result = entry.value;
              final background = index.isEven
                  ? const Color(0xFFFFFCF6)
                  : const Color(0xFFF7F1E8);

              return _TableRowShell(
                background: background,
                borderRadius: BorderRadius.zero,
                children: [
                  _TableCell(
                    width: widths[0],
                    child: Text('${result.rowIndex}'),
                  ),
                  _TableCell(width: widths[1], child: Text(result.name ?? '-')),
                  _TableCell(
                    width: widths[2],
                    child: Text(result.matricule ?? '-'),
                  ),
                  _TableCell(
                    width: widths[3],
                    alignment: Alignment.centerRight,
                    child: Text(result.finalScore?.toStringAsFixed(2) ?? '-'),
                  ),
                  _TableCell(
                    width: widths[4],
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _GradeBadge(letter: result.letter.label),
                    ),
                  ),
                  _TableCell(
                    width: widths[5],
                    child: Text(result.pass ? 'Yes' : 'No'),
                  ),
                  _TableCell(width: widths[6], child: Text(result.source)),
                ],
              );
            }),
            Container(
              width: widths.reduce((a, b) => a + b),
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF18314F),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssuePanel extends StatelessWidget {
  const _IssuePanel({required this.issues});

  final List<ValidationIssue> issues;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const _Panel(
        title: 'Validation And Processing Issues',
        eyebrow: 'Quality Check',
        subtitle: 'Everything is clean in the current batch.',
        child: Text('No issues detected.'),
      );
    }

    return _Panel(
      title: 'Validation And Processing Issues',
      eyebrow: 'Audit Trail',
      subtitle:
          'Each warning or error is separated visually so you can review edge cases quickly.',
      child: SizedBox(
        height: 290,
        child: ListView.separated(
          itemCount: issues.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final issue = issues[index];
            final accent = switch (issue.severity) {
              IssueSeverity.error => const Color(0xFFA33B2F),
              IssueSeverity.warning => const Color(0xFF9C6A1B),
              IssueSeverity.info => const Color(0xFF2A5B85),
            };

            return Container(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.withValues(alpha: 0.14)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 112,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(22),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.report_gmailerrorred_rounded,
                                color: accent,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  issue.code,
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Row ${issue.rowIndex}',
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            issue.message,
                            style: const TextStyle(
                              color: Color(0xFF2F3745),
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    required this.eyebrow,
    required this.subtitle,
  });

  final String title;
  final String eyebrow;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8DED1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141D2A38),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFB8743C),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF18212E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF596270),
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _RevealPanel extends StatelessWidget {
  const _RevealPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
    );
  }
}

class _TableRowShell extends StatelessWidget {
  const _TableRowShell({
    required this.children,
    required this.background,
    required this.borderRadius,
  });

  final List<Widget> children;
  final Color background;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: background, borderRadius: borderRadius),
      child: Row(children: children),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.width,
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final double width;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: child,
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final tone = _gradeTone(letter);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        letter,
        style: TextStyle(color: tone, fontWeight: FontWeight.w800),
      ),
    );
  }
}

Color _gradeTone(String letter) => switch (letter) {
  'A' => const Color(0xFF24706A),
  'B+' || 'B' => const Color(0xFF1C5C84),
  'C+' || 'C' => const Color(0xFFB8743C),
  'D+' || 'D' => const Color(0xFF8A5A2A),
  'F' || 'X' => const Color(0xFFA33B2F),
  _ => const Color(0xFF6B7280),
};
