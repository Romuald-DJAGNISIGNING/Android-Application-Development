import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/export_format.dart';
import '../../../core/models/export_target.dart';
import '../../../core/providers/grade_calculator_controller.dart';

class ImportPanel extends ConsumerWidget {
  const ImportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);
    final controller = ref.read(gradeCalculatorProvider.notifier);
    final canExport = state.report != null && !state.loading;
    final canShare = state.lastArtifact != null && !state.loading;
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
            final wide = constraints.maxWidth > 940;
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
                    'Delivery Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Load marks, calculate grades, and deliver the report anywhere you need it.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF16212E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose the export format, pick the destination, and share the latest file directly from the app.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _FeatureChip(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'PDF export',
                    ),
                    _FeatureChip(
                      icon: Icons.cloud_sync_outlined,
                      label: 'Cloud-ready folder copy',
                    ),
                    _FeatureChip(
                      icon: Icons.share_outlined,
                      label: 'System share action',
                    ),
                    _FeatureChip(
                      icon: Icons.factory_outlined,
                      label: 'Factory-based delivery',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Export Format',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF16212E),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ExportFormat.values
                      .map(
                        (format) => _ChoiceChipButton(
                          label: format.label,
                          selected: state.selectedExportFormat == format,
                          onTap: () => controller.selectExportFormat(format),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 22),
                Text(
                  'Destination',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF16212E),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ExportTarget.values
                      .map(
                        (target) => _TargetCard(
                          target: target,
                          selected: state.selectedExportTarget == target,
                          onTap: () => controller.selectExportTarget(target),
                        ),
                      )
                      .toList(growable: false),
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
                      onPressed: canExport ? controller.exportReport : null,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Export Selected Format'),
                    ),
                    OutlinedButton.icon(
                      onPressed: canShare ? controller.shareLatestExport : null,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share Latest Export'),
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
                  title: 'Selected Delivery Flow',
                  body:
                      '${state.selectedExportFormat.label} -> ${state.selectedExportTarget.label}. The exporter is picked through a factory so each format stays isolated from the grading engine.',
                  accent: const Color(0xFF24706A),
                  background: const Color(0xFFEAF4F2),
                  icon: Icons.account_tree_outlined,
                ),
                const SizedBox(height: 12),
                _StatusCard(
                  title: 'Processing Rule',
                  body:
                      'If the same student appears more than once, the last row is kept. Invalid or missing marks are marked X and listed in the issues panel.',
                  accent: const Color(0xFFB8743C),
                  background: const Color(0xFFF8EEE2),
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
                if (state.deliveryMessage != null) ...[
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: 'Latest Delivery',
                    body: state.deliveryMessage!,
                    accent: const Color(0xFF336C4F),
                    background: const Color(0xFFE7F3EB),
                    icon: Icons.workspace_premium_outlined,
                  ),
                ],
                if (state.lastArtifact != null) ...[
                  const SizedBox(height: 12),
                  _StatusCard(
                    title: 'Last File',
                    body:
                        '${state.lastArtifact!.fileName}\n${state.lastArtifact!.path}',
                    accent: const Color(0xFF72408C),
                    background: const Color(0xFFF0E8F6),
                    icon: Icons.folder_open_rounded,
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

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF18314F) : const Color(0xFFF8F2E8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF18314F) : const Color(0xFFE4D4BD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF2B3442),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final ExportTarget target;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF24706A) : const Color(0xFF8C7760);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF4F2) : const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: selected ? 0.4 : 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              target == ExportTarget.local
                  ? Icons.save_alt_rounded
                  : Icons.cloud_done_rounded,
              color: accent,
            ),
            const SizedBox(height: 10),
            Text(
              target.label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              target.description,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ],
        ),
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
