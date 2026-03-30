import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/student_input_parser.dart';
import '../models/chart_dataset.dart';
import '../models/export_artifact.dart';
import '../models/export_format.dart';
import '../models/export_target.dart';
import '../models/processing_report.dart';
import '../services/chart_data_builder.dart';
import '../services/file_import_service.dart';
import '../services/grading_engine.dart';
import '../services/export/desktop_cloud_sync_service.dart';
import '../services/export/report_delivery_service.dart';
import '../services/export/report_exporter_factory.dart';
import '../services/export/share_plus_report_share_service.dart';

class GradeCalculatorState {
  const GradeCalculatorState({
    this.loading = false,
    this.sourcePath,
    this.report,
    this.chart = const ChartDataset(points: []),
    this.error,
    this.deliveryMessage,
    this.lastArtifact,
    this.selectedExportFormat = ExportFormat.excel,
    this.selectedExportTarget = ExportTarget.local,
  });

  final bool loading;
  final String? sourcePath;
  final ProcessingReport? report;
  final ChartDataset chart;
  final String? error;
  final String? deliveryMessage;
  final ExportArtifact? lastArtifact;
  final ExportFormat selectedExportFormat;
  final ExportTarget selectedExportTarget;

  GradeCalculatorState copyWith({
    bool? loading,
    String? sourcePath,
    ProcessingReport? report,
    ChartDataset? chart,
    String? error,
    bool clearError = false,
    String? deliveryMessage,
    bool clearDeliveryMessage = false,
    ExportArtifact? lastArtifact,
    bool clearLastArtifact = false,
    ExportFormat? selectedExportFormat,
    ExportTarget? selectedExportTarget,
  }) {
    return GradeCalculatorState(
      loading: loading ?? this.loading,
      sourcePath: sourcePath ?? this.sourcePath,
      report: report ?? this.report,
      chart: chart ?? this.chart,
      error: clearError ? null : (error ?? this.error),
      deliveryMessage: clearDeliveryMessage
          ? null
          : (deliveryMessage ?? this.deliveryMessage),
      lastArtifact: clearLastArtifact ? null : (lastArtifact ?? this.lastArtifact),
      selectedExportFormat: selectedExportFormat ?? this.selectedExportFormat,
      selectedExportTarget: selectedExportTarget ?? this.selectedExportTarget,
    );
  }
}

class GradeCalculatorController extends Notifier<GradeCalculatorState> {
  final StudentInputParser _fileImportService = const FileImportService();
  final GradingEngine _gradingEngine = const GradingEngine();
  final ChartDataBuilder _chartBuilder = const ChartDataBuilder();
  final ReportDeliveryService _deliveryService = const ReportDeliveryService(
    exporterFactory: ReportExporterFactory(),
    cloudSyncService: DesktopCloudSyncService(),
    shareService: SharePlusReportShareService(),
  );

  @override
  GradeCalculatorState build() => const GradeCalculatorState();

  Future<void> importAndProcess() async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      clearDeliveryMessage: true,
      clearLastArtifact: true,
    );

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xlsx'],
        lockParentWindow: true,
      );

      final path = picked?.files.single.path;
      if (path == null) {
        state = state.copyWith(loading: false);
        return;
      }

      final rows = await _fileImportService.parseFile(path);
      final report = _gradingEngine.batchGrade(rows);

      state = state.copyWith(
        loading: false,
        sourcePath: path,
        report: report,
        chart: _chartBuilder.buildGradeDistribution(report),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  void selectExportFormat(ExportFormat format) {
    state = state.copyWith(selectedExportFormat: format);
  }

  void selectExportTarget(ExportTarget target) {
    state = state.copyWith(selectedExportTarget: target);
  }

  Future<void> exportReport() async {
    final report = state.report;
    if (report == null) {
      return;
    }

    state = state.copyWith(
      loading: true,
      clearError: true,
      clearDeliveryMessage: true,
    );

    try {
      final format = state.selectedExportFormat;
      final artifact = state.selectedExportTarget == ExportTarget.local
          ? await _exportToLocal(report, format)
          : await _exportToCloud(report, format);

      if (artifact == null) {
        state = state.copyWith(loading: false);
        return;
      }

      state = state.copyWith(
        loading: false,
        lastArtifact: artifact,
        deliveryMessage:
            '${artifact.format.label} saved to ${artifact.target.label.toLowerCase()}.',
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> shareLatestExport() async {
    final artifact = state.lastArtifact;
    if (artifact == null) {
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      await _deliveryService.shareArtifact(artifact);
      state = state.copyWith(
        loading: false,
        deliveryMessage: '${artifact.fileName} opened in the system share flow.',
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<ExportArtifact?> _exportToLocal(
    ProcessingReport report,
    ExportFormat format,
  ) async {
    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save ${format.label} report',
      fileName: format.suggestedFileName(),
      type: FileType.custom,
      allowedExtensions: [format.extension],
      lockParentWindow: true,
    );

    if (selectedPath == null) {
      return null;
    }

    final finalPath = _ensureExtension(selectedPath, format.extension);
    return _deliveryService.exportToPath(
      report: report,
      format: format,
      destinationPath: finalPath,
    );
  }

  Future<ExportArtifact?> _exportToCloud(
    ProcessingReport report,
    ExportFormat format,
  ) async {
    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose the synced cloud folder for ${format.label}',
      lockParentWindow: true,
    );

    if (directory == null) {
      return null;
    }

    return _deliveryService.exportToCloudDirectory(
      report: report,
      format: format,
      destinationDirectory: directory,
    );
  }

  String _ensureExtension(String path, String extension) {
    final lower = path.toLowerCase();
    return lower.endsWith('.$extension') ? path : '$path.$extension';
  }

  String get sourceFileName {
    final sourcePath = state.sourcePath;
    if (sourcePath == null || sourcePath.isEmpty) {
      return 'No file imported';
    }
    return File(sourcePath).uri.pathSegments.last;
  }
}

final gradeCalculatorProvider =
    NotifierProvider<GradeCalculatorController, GradeCalculatorState>(
      GradeCalculatorController.new,
    );
