class NumericParser {
  static const _missingTokens = {
    'na',
    'n/a',
    'none',
    'null',
    'absent',
    'missing',
    '-',
    '--',
    'x',
  };

  static double? parseFlexible(String? value) {
    if (value == null) {
      return null;
    }
    final compact = value.trim();
    if (compact.isEmpty) {
      return null;
    }
    if (_missingTokens.contains(compact.toLowerCase())) {
      return null;
    }

    // I normalize aggressively here because class files are usually messy.
    var normalized = compact.replaceAll(RegExp(r'\s+'), '');

    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll(',', '');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }

    normalized = normalized.replaceAll(RegExp(r'[^0-9.\-]'), '');

    if (normalized.isEmpty || normalized == '-' || normalized == '.') {
      return null;
    }

    final dotCount = '.'.allMatches(normalized).length;
    if (dotCount > 1) {
      return null;
    }

    return double.tryParse(normalized);
  }

  static bool inRange(double value, double min, double max) {
    return value >= min && value <= max;
  }
}
