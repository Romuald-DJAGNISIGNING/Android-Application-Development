import '../../contracts/report_exporter.dart';
import '../../models/export_format.dart';
import '../workbook_export_service.dart';
import 'csv_report_exporter.dart';
import 'json_report_exporter.dart';
import 'pdf_report_exporter.dart';
import 'word_report_exporter.dart';

class ReportExporterFactory {
  const ReportExporterFactory({
    this.excelExporter = const WorkbookExportService(),
    this.csvExporter = const CsvReportExporter(),
    this.jsonExporter = const JsonReportExporter(),
    this.pdfExporter = const PdfReportExporter(),
    this.wordExporter = const WordReportExporter(),
  });

  final ReportExporter excelExporter;
  final ReportExporter csvExporter;
  final ReportExporter jsonExporter;
  final ReportExporter pdfExporter;
  final ReportExporter wordExporter;

  ReportExporter create(ExportFormat format) => switch (format) {
    ExportFormat.excel => excelExporter,
    ExportFormat.csv => csvExporter,
    ExportFormat.json => jsonExporter,
    ExportFormat.pdf => pdfExporter,
    ExportFormat.word => wordExporter,
  };
}
