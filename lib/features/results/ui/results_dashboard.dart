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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryStrip(summary: report.summary),
        const SizedBox(height: 16),
        _ChartPanel(chart: state.chart),
        const SizedBox(height: 16),
        _PreviewPanel(results: report.results),
        const SizedBox(height: 16),
        _IssuePanel(issues: report.issues),
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
    final entries = [
      ('Rows', summary.totalRows.toString(), const Color(0xFF0E5A8A)),
      ('Average', fmt.format(summary.average), const Color(0xFF1C8D74)),
      ('Median', fmt.format(summary.median), const Color(0xFFB46B00)),
      (
        'Pass Rate',
        '${fmt.format(summary.passRate)}%',
        const Color(0xFF5E3AA8),
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: entries
          .map(
            (entry) =>
                _KpiCard(label: entry.$1, value: entry.$2, accent: entry.$3),
          )
          .toList(growable: false),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.90),
            accent.withValues(alpha: 0.74),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 860) {
            return SizedBox(
              height: 280,
              child: Row(
                children: [
                  Expanded(child: _Pie(chart: chart)),
                  const SizedBox(width: 16),
                  Expanded(child: _Legend(chart: chart)),
                ],
              ),
            );
          }

          return Column(
            children: [
              SizedBox(height: 260, child: _Pie(chart: chart)),
              const SizedBox(height: 12),
              SizedBox(height: 180, child: _Legend(chart: chart)),
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
      Color(0xFF1C8D74),
      Color(0xFF0E5A8A),
      Color(0xFF5E3AA8),
      Color(0xFFB46B00),
      Color(0xFF64748B),
      Color(0xFFB91C1C),
      Color(0xFF1E40AF),
      Color(0xFF7C2D12),
      Color(0xFF0F172A),
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: chart.points
            .asMap()
            .entries
            .map((entry) {
              final point = entry.value;
              return PieChartSectionData(
                title: point.label,
                value: point.count.toDouble(),
                radius: 82,
                color: colors[entry.key % colors.length],
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              );
            })
            .toList(growable: false),
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
    return ListView.builder(
      itemCount: chart.points.length,
      itemBuilder: (context, index) {
        final point = chart.points[index];
        final ratio = total == 0 ? 0 : (point.count / total) * 100;
        return ListTile(
          dense: true,
          title: Text('Grade ${point.label}'),
          trailing: Text('${point.count} (${ratio.toStringAsFixed(1)}%)'),
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
    // I keep the UI preview intentionally small so huge classes stay smooth.
    final preview = results.take(15).toList(growable: false);
    final textTheme = Theme.of(context).textTheme;

    return _Panel(
      title: 'Processed Rows (Preview)',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          columns: const [
            DataColumn(label: Text('Row')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Matricule')),
            DataColumn(label: Text('Score')),
            DataColumn(label: Text('Letter')),
            DataColumn(label: Text('Pass')),
            DataColumn(label: Text('Source')),
          ],
          rows: preview
              .map(
                (result) => DataRow(
                  cells: [
                    DataCell(Text('${result.rowIndex}')),
                    DataCell(Text(result.name ?? '-')),
                    DataCell(Text(result.matricule ?? '-')),
                    DataCell(
                      Text(result.finalScore?.toStringAsFixed(2) ?? '-'),
                    ),
                    DataCell(Text(result.letter.label)),
                    DataCell(Text(result.pass ? 'Yes' : 'No')),
                    DataCell(Text(result.source)),
                  ],
                ),
              )
              .toList(growable: false),
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
        title: 'Validation & Processing Issues',
        child: Text('No issues detected.'),
      );
    }

    return _Panel(
      title: 'Validation & Processing Issues (${issues.length})',
      child: SizedBox(
        height: 240,
        child: ListView.separated(
          itemCount: issues.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final issue = issues[index];
            final accent = switch (issue.severity) {
              IssueSeverity.error => const Color(0xFFB71C1C),
              IssueSeverity.warning => const Color(0xFFA16207),
              IssueSeverity.info => const Color(0xFF0E5A8A),
            };
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.report_gmailerrorred_rounded,
                    color: accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '[Row ${issue.rowIndex}] ${issue.code}: ${issue.message}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
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
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      shadowColor: const Color(0x1509203F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
