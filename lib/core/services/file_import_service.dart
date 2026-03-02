import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../models/student_input_row.dart';
import 'column_mapping_config.dart';

class FileImportService {
  const FileImportService({this.mapping = ColumnMappingConfig.defaults});

  final ColumnMappingConfig mapping;

  Future<List<StudentInputRow>> parseFile(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.csv')) {
      return parseCsv(path);
    }
    if (lower.endsWith('.xlsx')) {
      return parseXlsx(path);
    }
    throw UnsupportedError('Only .csv and .xlsx are supported.');
  }

  Future<List<StudentInputRow>> parseCsv(String path) async {
    final content = await File(path).readAsString();
    final rows = csv.decode(content);

    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first.map((value) => value.toString()).toList();
    final canonicalIndices = _canonicalIndices(headers);
    final output = <StudentInputRow>[];

    for (var i = 1; i < rows.length; i++) {
      output.add(_rowFromCells(i + 1, headers, rows[i], canonicalIndices));
    }

    return output;
  }

  Future<List<StudentInputRow>> parseXlsx(String path) async {
    final bytes = await File(path).readAsBytes();
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      return const [];
    }

    final sheet = workbook.tables.values.first;
    final rows = sheet.rows;
    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first
        .map((cell) => cell?.value?.toString() ?? '')
        .toList(growable: false);
    final canonicalIndices = _canonicalIndices(headers);

    final output = <StudentInputRow>[];
    for (var i = 1; i < rows.length; i++) {
      final rowCells = rows[i]
          .map((cell) => cell?.value?.toString() ?? '')
          .toList(growable: false);
      output.add(_rowFromCells(i + 1, headers, rowCells, canonicalIndices));
    }

    return output;
  }

  Map<String, int> _canonicalIndices(List<String> headers) {
    final result = <String, int>{};
    for (var index = 0; index < headers.length; index++) {
      final canonical = mapping.resolveCanonical(headers[index]);
      if (canonical != null && !result.containsKey(canonical)) {
        result[canonical] = index;
      }
    }
    return result;
  }

  StudentInputRow _rowFromCells(
    int rowIndex,
    List<String> headers,
    List<dynamic> row,
    Map<String, int> canonicalIndices,
  ) {
    final raw = <String, String?>{};
    for (var i = 0; i < headers.length; i++) {
      final value = i < row.length ? row[i]?.toString() : null;
      raw[headers[i]] = value?.trim().isEmpty == true ? null : value?.trim();
    }

    String? valueFor(String key) {
      final index = canonicalIndices[key];
      if (index == null || index >= headers.length) {
        return null;
      }
      return raw[headers[index]];
    }

    return StudentInputRow(
      rowIndex: rowIndex,
      name: valueFor('name'),
      matricule: valueFor('matricule'),
      ca: valueFor('ca'),
      exam: valueFor('exam'),
      total: valueFor('total'),
      rawValues: raw,
    );
  }
}
