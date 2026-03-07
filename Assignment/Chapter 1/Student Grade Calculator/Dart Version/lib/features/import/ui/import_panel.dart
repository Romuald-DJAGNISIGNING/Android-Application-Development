import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/grade_calculator_controller.dart';

class ImportPanel extends ConsumerWidget {
  const ImportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);
    final controller = ref.read(gradeCalculatorProvider.notifier);
    final canExport = state.report != null && !state.loading;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE7DDCF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141D2A38),
            blurRadius: 26,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 860;
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18314F),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Import',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Load student marks and create the final report.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF16212E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose a CSV or XLSX file, process the marks, and export the result as an Excel workbook.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _FeatureChip(
                      icon: Icons.rule_folder_outlined,
                      label: 'Grade rules',
                    ),
                    _FeatureChip(
                      icon: Icons.auto_graph_rounded,
                      label: 'Summary chart',
                    ),
                    _FeatureChip(
                      icon: Icons.table_chart_rounded,
                      label: 'Excel export',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: state.loading
                          ? null
                          : controller.importAndProcess,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Import File'),
                    ),
                    OutlinedButton.icon(
                      onPressed: canExport ? controller.exportWorkbook : null,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Export Workbook'),
                    ),
                  ],
                ),
              ],
            );

            final right = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(
                  title: 'Source File',
                  body: controller.sourceFileName,
                  accent: const Color(0xFF18314F),
                  background: const Color(0xFFF2EFE8),
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 12),
                _StatusCard(
                  title: 'Processing Rule',
                  body:
                      'If the same student appears more than once, the last row is kept. Invalid or missing marks are marked X.',
                  accent: const Color(0xFF24706A),
                  background: const Color(0xFFEAF4F2),
                  icon: Icons.verified_outlined,
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: 'Current Alert',
                    body: state.error!,
                    accent: const Color(0xFFA33B2F),
                    background: const Color(0xFFFBE6E3),
                    icon: Icons.report_gmailerrorred_rounded,
                  ),
                ],
                if (state.lastExportPath != null) ...[
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: 'Latest Export',
                    body: state.lastExportPath!,
                    accent: const Color(0xFF336C4F),
                    background: const Color(0xFFE7F3EB),
                    icon: Icons.workspace_premium_outlined,
                  ),
                ],
              ],
            );

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [left, const SizedBox(height: 18), right],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: left),
                const SizedBox(width: 22),
                Expanded(flex: 2, child: right),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4D4BD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFB8743C), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2B3442),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.body,
    required this.accent,
    required this.background,
    required this.icon,
  });

  final String title;
  final String body;
  final Color accent;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF2E3A48),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
