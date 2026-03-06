import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../models/grade_config.dart';
import '../models/processing_report.dart';
import '../models/validation_issue.dart';

class ExportResult {
  const ExportResult({required this.path, required this.sizeBytes});

  final String path;
  final int sizeBytes;
}

class WorkbookExportService {
  const WorkbookExportService();

  Future<ExportResult> export(
    ProcessingReport report,
    String destinationPath,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final gradesSheet = excel['Grades'];
    final summarySheet = excel['Summary'];
    final issuesSheet = excel['Issues'];
    final chartSheet = excel['ChartData'];

    _fillGrades(gradesSheet, report);
    _fillSummary(summarySheet, report);
    _fillIssues(issuesSheet, report);
    _fillChartData(chartSheet, report);

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Could not generate workbook bytes.');
    }

    final file = File(destinationPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return ExportResult(path: destinationPath, sizeBytes: bytes.length);
  }

  void _fillGrades(Sheet sheet, ProcessingReport report) {
    final headers = [
      'Row',
      'Name',
      'Matricule',
      'Final Score',
      'Letter',
      'Pass',
      'Status',
      'Source',
      'Reasons',
    ];

    _decorateSheet(
      sheet,
      title: 'Student Grade Report',
      subtitle:
          'Prepared from the Dart desktop dashboard on ${DateFormat('MMM d, y - HH:mm').format(DateTime.now())}',
      widths: [8, 24, 18, 14, 10, 10, 16, 22, 42],
      lastColumn: headers.length - 1,
    );

    _appendHeader(sheet, headers, rowIndex: 3);

    for (var index = 0; index < report.results.length; index++) {
      final result = report.results[index];
      final rowIndex = index + 4;

      _writeRow(sheet, rowIndex, [
        IntCellValue(result.rowIndex),
        TextCellValue(result.name ?? ''),
        TextCellValue(result.matricule ?? ''),
        result.finalScore == null
            ? TextCellValue('')
            : DoubleCellValue(result.finalScore!),
        TextCellValue(result.letter.label),
        TextCellValue(result.pass ? 'YES' : 'NO'),
        TextCellValue(result.status.name.toUpperCase()),
        TextCellValue(result.source),
        TextCellValue(result.reasons.join(' | ')),
      ]);

      final rowStyle = _gradeRowStyle(result.letter.label);
      for (var col = 0; col < headers.length; col++) {
        _cell(sheet, col, rowIndex).cellStyle = rowStyle;
      }

      _cell(sheet, 3, rowIndex).cellStyle = rowStyle.copyWith(
        horizontalAlignVal: HorizontalAlign.Right,
        numberFormat: NumFormat.standard_2,
      );
      _cell(sheet, 4, rowIndex).cellStyle = _gradeBadgeStyle(
        result.letter.label,
      );
      _cell(sheet, 5, rowIndex).cellStyle = _passStyle(result.pass);
      _cell(sheet, 8, rowIndex).cellStyle = rowStyle.copyWith(
        textWrappingVal: TextWrapping.WrapText,
      );
      sheet.setRowHeight(rowIndex, 24);
    }
  }

  void _fillSummary(Sheet sheet, ProcessingReport report) {
    _decorateSheet(
      sheet,
      title: 'Executive Summary',
      subtitle:
          'A polished overview of performance, pass rate, and grade spread.',
      widths: [28, 14],
      lastColumn: 1,
    );

    _appendHeader(sheet, ['Metric', 'Value'], rowIndex: 3);
    final summary = report.summary;
    final metrics = [
      ('Total Rows', summary.totalRows.toString()),
      ('Graded Rows', summary.gradedRows.toString()),
      ('Unknown Rows', summary.unknownRows.toString()),
      ('Average Score', summary.average.toStringAsFixed(2)),
      ('Median Score', summary.median.toStringAsFixed(2)),
      ('Pass Rate %', summary.passRate.toStringAsFixed(2)),
    ];

    for (var index = 0; index < metrics.length; index++) {
      final rowIndex = index + 4;
      final metric = metrics[index];
      _writeRow(sheet, rowIndex, [
        TextCellValue(metric.$1),
        TextCellValue(metric.$2),
      ]);
      _cell(sheet, 0, rowIndex).cellStyle = _metricLabelStyle();
      _cell(sheet, 1, rowIndex).cellStyle = _metricValueStyle();
    }

    final sectionRow = metrics.length + 6;
    _writeRow(sheet, sectionRow, [
      TextCellValue('Grade Breakdown'),
      TextCellValue('Count'),
    ]);
    _applyRowStyle(sheet, sectionRow, 2, _sectionHeaderStyle());

    for (var index = 0; index < summary.gradeCounts.entries.length; index++) {
      final entry = summary.gradeCounts.entries.elementAt(index);
      final rowIndex = sectionRow + 1 + index;
      _writeRow(sheet, rowIndex, [
        TextCellValue(entry.key.label),
        IntCellValue(entry.value),
      ]);
      _cell(sheet, 0, rowIndex).cellStyle = _gradeBadgeStyle(entry.key.label);
      _cell(sheet, 1, rowIndex).cellStyle = _metricValueStyle();
    }
  }

  void _fillIssues(Sheet sheet, ProcessingReport report) {
    _decorateSheet(
      sheet,
      title: 'Issue Register',
      subtitle: 'Every warning, fallback, and error surfaced during grading.',
      widths: [8, 14, 18, 56],
      lastColumn: 3,
    );

    _appendHeader(sheet, ['Row', 'Severity', 'Code', 'Message'], rowIndex: 3);

    for (var index = 0; index < report.issues.length; index++) {
      final issue = report.issues[index];
      final rowIndex = index + 4;

      _writeRow(sheet, rowIndex, [
        IntCellValue(issue.rowIndex),
        TextCellValue(issue.severity.name.toUpperCase()),
        TextCellValue(issue.code),
        TextCellValue(issue.message),
      ]);

      final style = _severityStyle(issue.severity);
      _applyRowStyle(sheet, rowIndex, 4, style);
      _cell(sheet, 3, rowIndex).cellStyle = style.copyWith(
        textWrappingVal: TextWrapping.WrapText,
      );
      sheet.setRowHeight(rowIndex, 28);
    }
  }

  void _fillChartData(Sheet sheet, ProcessingReport report) {
    _decorateSheet(
      sheet,
      title: 'Chart Data',
      subtitle: 'Clean counts ready for chart recreation or lecturer review.',
      widths: [14, 12],
      lastColumn: 1,
    );

    _appendHeader(sheet, ['Grade', 'Count'], rowIndex: 3);
    for (
      var index = 0;
      index < report.summary.gradeCounts.entries.length;
      index++
    ) {
      final entry = report.summary.gradeCounts.entries.elementAt(index);
      final rowIndex = index + 4;
      _writeRow(sheet, rowIndex, [
        TextCellValue(entry.key.label),
        IntCellValue(entry.value),
      ]);
      _cell(sheet, 0, rowIndex).cellStyle = _gradeBadgeStyle(entry.key.label);
      _cell(sheet, 1, rowIndex).cellStyle = _metricValueStyle();
    }
  }

  void _decorateSheet(
    Sheet sheet, {
    required String title,
    required String subtitle,
    required List<double> widths,
    required int lastColumn,
  }) {
    for (var index = 0; index < widths.length; index++) {
      sheet.setColumnWidth(index, widths[index]);
    }

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 0),
      customValue: TextCellValue(title),
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 1),
      customValue: TextCellValue(subtitle),
    );

    _cell(sheet, 0, 0).cellStyle = _titleStyle();
    _cell(sheet, 0, 1).cellStyle = _subtitleStyle();
    sheet.setRowHeight(0, 30);
    sheet.setRowHeight(1, 22);
  }

  void _appendHeader(
    Sheet sheet,
    List<String> titles, {
    required int rowIndex,
  }) {
    for (var col = 0; col < titles.length; col++) {
      _cell(sheet, col, rowIndex).value = TextCellValue(titles[col]);
    }
    _applyRowStyle(sheet, rowIndex, titles.length, _headerStyle());
    sheet.setRowHeight(rowIndex, 22);
  }

  void _writeRow(Sheet sheet, int rowIndex, List<CellValue?> values) {
    for (var col = 0; col < values.length; col++) {
      _cell(sheet, col, rowIndex).value = values[col];
    }
  }

  void _applyRowStyle(
    Sheet sheet,
    int rowIndex,
    int columnCount,
    CellStyle style,
  ) {
    for (var col = 0; col < columnCount; col++) {
      _cell(sheet, col, rowIndex).cellStyle = style;
    }
  }

  Data _cell(Sheet sheet, int columnIndex, int rowIndex) {
    return sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: rowIndex),
    );
  }

  CellStyle _titleStyle() => CellStyle(
    bold: true,
    fontSize: 20,
    fontFamily: getFontFamily(FontFamily.Cambria),
    fontColorHex: ExcelColor.white,
    backgroundColorHex: '#18314F'.excelColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
    bottomBorder: _border('#18314F'),
  );

  CellStyle _subtitleStyle() => CellStyle(
    italic: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: '#35506B'.excelColor,
    backgroundColorHex: '#EAE2D7'.excelColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
    bottomBorder: _border('#D8C8B1'),
  );

  CellStyle _headerStyle() => CellStyle(
    bold: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: ExcelColor.white,
    backgroundColorHex: '#24486D'.excelColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.WrapText,
    leftBorder: _border('#24486D'),
    rightBorder: _border('#24486D'),
    topBorder: _border('#24486D'),
    bottomBorder: _border('#24486D'),
  );

  CellStyle _sectionHeaderStyle() => CellStyle(
    bold: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: ExcelColor.white,
    backgroundColorHex: '#B8743C'.excelColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    leftBorder: _border('#B8743C'),
    rightBorder: _border('#B8743C'),
    topBorder: _border('#B8743C'),
    bottomBorder: _border('#B8743C'),
  );

  CellStyle _metricLabelStyle() => CellStyle(
    bold: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: '#223145'.excelColor,
    backgroundColorHex: '#F6EFE3'.excelColor,
    leftBorder: _border('#E0D5C3'),
    rightBorder: _border('#E0D5C3'),
    topBorder: _border('#E0D5C3'),
    bottomBorder: _border('#E0D5C3'),
  );

  CellStyle _metricValueStyle() => CellStyle(
    bold: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: '#18314F'.excelColor,
    backgroundColorHex: '#FFFDFC'.excelColor,
    horizontalAlign: HorizontalAlign.Right,
    leftBorder: _border('#E7DED1'),
    rightBorder: _border('#E7DED1'),
    topBorder: _border('#E7DED1'),
    bottomBorder: _border('#E7DED1'),
  );

  CellStyle _gradeRowStyle(String grade) => CellStyle(
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: '#243142'.excelColor,
    backgroundColorHex: _gradeFill(grade).excelColor,
    verticalAlign: VerticalAlign.Center,
    leftBorder: _border('#E2D8CB'),
    rightBorder: _border('#E2D8CB'),
    topBorder: _border('#E2D8CB'),
    bottomBorder: _border('#E2D8CB'),
  );

  CellStyle _gradeBadgeStyle(String grade) => CellStyle(
    bold: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: _gradeText(grade).excelColor,
    backgroundColorHex: _gradeFill(grade).excelColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    leftBorder: _border('#E2D8CB'),
    rightBorder: _border('#E2D8CB'),
    topBorder: _border('#E2D8CB'),
    bottomBorder: _border('#E2D8CB'),
  );

  CellStyle _passStyle(bool passed) => CellStyle(
    bold: true,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: passed ? '#1E5B45'.excelColor : '#A33B2F'.excelColor,
    backgroundColorHex: passed ? '#E7F3EB'.excelColor : '#FBE6E3'.excelColor,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    leftBorder: _border('#E2D8CB'),
    rightBorder: _border('#E2D8CB'),
    topBorder: _border('#E2D8CB'),
    bottomBorder: _border('#E2D8CB'),
  );

  CellStyle _severityStyle(IssueSeverity severity) => CellStyle(
    bold: severity != IssueSeverity.info,
    fontSize: 11,
    fontFamily: getFontFamily(FontFamily.Corbel),
    fontColorHex: switch (severity) {
      IssueSeverity.error => '#8E3128'.excelColor,
      IssueSeverity.warning => '#8D631F'.excelColor,
      IssueSeverity.info => '#2F587E'.excelColor,
    },
    backgroundColorHex: switch (severity) {
      IssueSeverity.error => '#FBE6E3'.excelColor,
      IssueSeverity.warning => '#FAF0D9'.excelColor,
      IssueSeverity.info => '#E6EFFA'.excelColor,
    },
    verticalAlign: VerticalAlign.Center,
    leftBorder: _border('#E2D8CB'),
    rightBorder: _border('#E2D8CB'),
    topBorder: _border('#E2D8CB'),
    bottomBorder: _border('#E2D8CB'),
  );

  Border _border(String hex) =>
      Border(borderStyle: BorderStyle.Thin, borderColorHex: hex.excelColor);

  String _gradeFill(String grade) => switch (grade) {
    'A' => '#D9EFE8',
    'B+' || 'B' => '#E3ECF8',
    'C+' || 'C' => '#F8E9D7',
    'D+' || 'D' => '#F6E2C5',
    'F' || 'X' => '#F7DEDA',
    _ => '#F6F1E8',
  };

  String _gradeText(String grade) => switch (grade) {
    'A' => '#1F5B53',
    'B+' || 'B' => '#1D4E72',
    'C+' || 'C' => '#8B5C1E',
    'D+' || 'D' => '#87562A',
    'F' || 'X' => '#963A30',
    _ => '#243142',
  };
}
