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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5ECF7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1509203F),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Student Marks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'CSV/XLSX only. Latest duplicate row wins, and every issue is logged.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: state.loading ? null : controller.importAndProcess,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Import & Process'),
                ),
                FilledButton.tonalIcon(
                  onPressed: canExport ? controller.exportWorkbook : null,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export Workbook'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _metaChip(
              icon: Icons.description_outlined,
              text: controller.sourceFileName,
              iconColor: const Color(0xFF0E5A8A),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              _metaChip(
                icon: Icons.error_outline_rounded,
                text: state.error!,
                iconColor: const Color(0xFFB71C1C),
                background: const Color(0xFFFFEBEE),
              ),
            ],
            if (state.lastExportPath != null) ...[
              const SizedBox(height: 12),
              _metaChip(
                icon: Icons.check_circle_outline_rounded,
                text: 'Workbook saved to: ${state.lastExportPath}',
                iconColor: const Color(0xFF1B5E20),
                background: const Color(0xFFE8F5E9),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    required Color iconColor,
    Color background = const Color(0xFFF1F5F9),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
