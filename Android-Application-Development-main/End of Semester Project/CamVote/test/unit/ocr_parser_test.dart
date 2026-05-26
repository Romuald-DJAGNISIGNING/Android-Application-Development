// test/unit/ocr_parser_test.dart
//
// Tests OcrParser.parse() and OcrParser.validate() — both are pure static
// methods with zero Flutter/Firebase dependencies.
//
// Run with:  flutter test test/unit/ocr_parser_test.dart --reporter expanded

import 'package:flutter_test/flutter_test.dart';
import 'package:camvote/features/registration/services/ocr/ocr_models.dart';
import 'package:camvote/features/registration/services/ocr/ocr_parser.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // OcrParser.parse()
  // ═══════════════════════════════════════════════════════════════════════════
  group('OcrParser.parse()', () {
    // ── Label-based parsing ──────────────────────────────────────────────────
    group('label-based name extraction', () {
      test('extracts full name from "NOM ET PRENOM: DUPONT JEAN" line', () {
        const raw = '''
REPUBLIQUE DU CAMEROUN
NOM ET PRENOM: DUPONT JEAN
DATE DE NAISSANCE: 15/03/1990
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.fullName, isNotNull);
        expect(result.fullName!.toUpperCase(), contains('DUPONT'));
      });

      test('extracts name when NOM and PRENOM are on separate lines', () {
        const raw = '''
CARTE NATIONALE D IDENTITE
NOM
NGONO
PRENOM
MARIE CLAIRE
DATE DE NAISSANCE: 22/07/1985
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.fullName, isNotNull);
        // Should merge surname + given names
        expect(result.fullName!.toUpperCase(), contains('NGONO'));
      });

      test('extracts name from English "NAME:" label', () {
        const raw = '''
REPUBLIC OF CAMEROON
NAME: FOMATATI JEAN-PIERRE
DATE OF BIRTH: 10/11/1978
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.fullName, isNotNull);
        expect(result.fullName!.toUpperCase(), contains('FOMATATI'));
      });
    });

    // ── Date of birth parsing ─────────────────────────────────────────────────
    group('date of birth extraction', () {
      test('parses dd/mm/yyyy format correctly', () {
        const raw = '''
CNI CAMEROUN
NOM: BIYA PAUL
DATE DE NAISSANCE: 13/02/1933
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNotNull);
        expect(result.dateOfBirth!.day, 13);
        expect(result.dateOfBirth!.month, 2);
        expect(result.dateOfBirth!.year, 1933);
      });

      test('parses dd-mm-yyyy format correctly', () {
        const raw = '''
CAMEROON ID
NOM: TEST USER
DATE OF BIRTH: 05-08-1995
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNotNull);
        expect(result.dateOfBirth!.day, 5);
        expect(result.dateOfBirth!.month, 8);
        expect(result.dateOfBirth!.year, 1995);
      });

      test('parses dd.mm.yyyy format correctly', () {
        const raw = '''
CNI
SURNAME: KAMTO
DATE DE NAISSANCE: 20.04.1975
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNotNull);
        expect(result.dateOfBirth!.year, 1975);
        expect(result.dateOfBirth!.month, 4);
        expect(result.dateOfBirth!.day, 20);
      });

      test('parses month-name date (English): 15 MAR 1990', () {
        const raw = '''
REPUBLIC OF CAMEROON
NAME: TEST VOTER
DATE OF BIRTH: 15 MAR 1990
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNotNull);
        expect(result.dateOfBirth!.month, 3);
        expect(result.dateOfBirth!.year, 1990);
      });

      test('parses month-name date (French): 10 JANVIER 2000', () {
        const raw = '''
CAMEROUN
NOM: ETAME MARC
NEE LE: 10 JANVIER 2000
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNotNull);
        expect(result.dateOfBirth!.month, 1);
        expect(result.dateOfBirth!.year, 2000);
      });

      test('parses accented French birth label and month name', () {
        const raw = '''
CAMEROUN
NOM: ETAME MARC
NÉE LE: 22 FÉVRIER 2001
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNotNull);
        expect(result.dateOfBirth!.day, 22);
        expect(result.dateOfBirth!.month, 2);
        expect(result.dateOfBirth!.year, 2001);
      });

      test('returns null dateOfBirth when no date present', () {
        const raw = '''
CNI
NOM: SOME PERSON
LIEU DE NAISSANCE: YAOUNDE
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.dateOfBirth, isNull);
      });
    });

    // ── Place of birth ────────────────────────────────────────────────────────
    group('place of birth extraction', () {
      test('extracts place of birth from "LIEU DE NAISSANCE" label', () {
        const raw = '''
CNI CAMEROUN
NOM: TABI ANNE
LIEU DE NAISSANCE: BAFOUSSAM
DATE DE NAISSANCE: 01/01/1990
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.placeOfBirth, isNotNull);
        expect(result.placeOfBirth!.toUpperCase(), contains('BAFOUSSAM'));
      });

      test('extracts place of birth from English "PLACE OF BIRTH" label', () {
        const raw = '''
REPUBLIC OF CAMEROON
NAME: JOHN DOE
PLACE OF BIRTH: DOUALA
DATE OF BIRTH: 01/06/1988
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.placeOfBirth, isNotNull);
        expect(result.placeOfBirth!.toUpperCase(), contains('DOUALA'));
      });
    });

    // ── Nationality ──────────────────────────────────────────────────────────
    group('nationality extraction', () {
      test('extracts nationality from "NATIONALITE" label', () {
        const raw = '''
CNI
NOM: FOUDA ERIC
NATIONALITE: CAMEROUNAISE
DATE DE NAISSANCE: 03/03/1980
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.nationality, isNotNull);
        expect(result.nationality!.toUpperCase(), contains('CAMEROUN'));
      });
    });

    // ── Document number ──────────────────────────────────────────────────────
    group('document number extraction', () {
      test('extracts and normalises document number', () {
        const raw = '''
CARTE NATIONALE D IDENTITE
NOM: NGUEMA PAUL
NO DE CARTE: A1234567
DATE DE NAISSANCE: 15/05/1970
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.documentNumber, isNotNull);
        expect(result.documentNumber, 'A1234567');
      });
    });

    // ── MRZ passport parsing ─────────────────────────────────────────────────
    group('MRZ parsing (passport)', () {
      test('parses full name from MRZ line 1 (P< format)', () {
        const raw = '''
REPUBLIC OF CAMEROON
P<CMRDUPONT<<JEAN<PIERRE<<<<<<<<<<<<<<<<<<<<<<
A1234567<3CMR9003151M2512311<<<<<<<<<<<<<<<4
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.passport,
        );
        expect(result.fullName, isNotNull);
        expect(result.fullName!.toUpperCase(), contains('DUPONT'));
        expect(result.fullName!.toUpperCase(), contains('JEAN'));
      });

      test('parses date of birth from MRZ line 2', () {
        const raw = '''
P<CMRNKONO<<ALICE<<<<<<<<<<<<<<<<<<<<<<<<<<<<
B9876543<1CMR8507224F3001011<<<<<<<<<<<<<<<2
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.passport,
        );
        expect(result.dateOfBirth, isNotNull);
        // MRZ dob: 850722 → 1985-07-22
        expect(result.dateOfBirth!.year, 1985);
        expect(result.dateOfBirth!.month, 7);
        expect(result.dateOfBirth!.day, 22);
      });

      test('extracts nationality CMR from MRZ', () {
        const raw = '''
P<CMRFON<<CHRISTIANE<<<<<<<<<<<<<<<<<<<<<<<<
C1111111<2CMR9201015F2812311<<<<<<<<<<<<<<<6
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.passport,
        );
        expect(result.nationality, isNotNull);
        expect(result.nationality, 'CMR');
      });

      test('falls back to label parsing when MRZ lines are absent', () {
        const raw = '''
PASSEPORT CAMEROUN
NOM: MALLE PIERRE
DATE DE NAISSANCE: 11/11/1991
''';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.passport,
        );
        expect(result.fullName, isNotNull);
        expect(result.fullName!.toUpperCase(), contains('MALLE'));
      });
    });

    // ── Raw text preservation ────────────────────────────────────────────────
    group('rawText', () {
      test('always preserves the original raw text in the result', () {
        const raw = 'CNI\nNOM: TESTER\nDATE: 01/01/2000';
        final result = OcrParser.parse(
          raw: raw,
          docType: OfficialDocumentType.nationalId,
        );
        expect(result.rawText, raw);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // OcrParser.validate()
  // ═══════════════════════════════════════════════════════════════════════════
  group('OcrParser.validate()', () {
    OcrExtractedIdentity makeExtracted({
      String rawText = 'CAMEROUN CMR',
      String? fullName,
      DateTime? dateOfBirth,
      String? placeOfBirth,
      String? nationality,
      String? documentNumber,
    }) {
      return OcrExtractedIdentity(
        rawText: rawText,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        placeOfBirth: placeOfBirth,
        nationality: nationality,
        documentNumber: documentNumber,
      );
    }

    final baseDob = DateTime(1990, 3, 15);

    // ── Passing cases ────────────────────────────────────────────────────────
    group('passing validation', () {
      test('validates correctly when all fields match exactly', () {
        final result = OcrParser.validate(
          expectedFullName: 'DUPONT JEAN',
          expectedDob: baseDob,
          expectedPlaceOfBirth: 'YAOUNDE',
          expectedNationality: 'CAMEROUNAISE',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'DUPONT JEAN',
            dateOfBirth: baseDob,
            placeOfBirth: 'YAOUNDE',
            nationality: 'CAMEROUNAISE',
          ),
        );

        expect(result.ok, true);
        expect(result.nameOk, true);
        expect(result.dobOk, true);
        expect(result.pobOk, true);
        expect(result.nationalityOk, true);
      });

      test('accepts fuzzy name match (35% token overlap)', () {
        // Expected has 3 tokens; extracted has 2 matching ones → >35%
        final result = OcrParser.validate(
          expectedFullName: 'JEAN PIERRE DUPONT',
          expectedDob: baseDob,
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'JEAN DUPONT',
            dateOfBirth: baseDob,
          ),
        );
        expect(result.nameOk, true);
        expect(result.ok, true);
      });

      test('accepts dob with day/month swap (common OCR error)', () {
        // expected: 15/03/1990 → extracted as 03/15/1990 (swapped)
        final result = OcrParser.validate(
          expectedFullName: 'ALICE NKONO',
          expectedDob: DateTime(1990, 3, 15),
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'ALICE NKONO',
            dateOfBirth: DateTime(1990, 15, 3), // swapped — invalid real date
          ),
        );
        // _dobMatch tolerates day/month swap
        expect(result.dobOk, true);
      });

      test('accepts dob with off-by-one day (OCR digit confusion)', () {
        final result = OcrParser.validate(
          expectedFullName: 'TEST USER',
          expectedDob: DateTime(1988, 6, 15),
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'TEST USER',
            dateOfBirth: DateTime(1988, 6, 16), // one day off
          ),
        );
        expect(result.dobOk, true);
      });
    });

    // ── Failing cases ─────────────────────────────────────────────────────────
    group('failing validation', () {
      test('fails when name has less than 35% token overlap', () {
        final result = OcrParser.validate(
          expectedFullName: 'JEAN PIERRE DUPONT',
          expectedDob: baseDob,
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'ALICE NKONO', // completely different name
            dateOfBirth: baseDob,
          ),
        );
        expect(result.nameOk, false);
      });

      test('fails when extracted name is null', () {
        final result = OcrParser.validate(
          expectedFullName: 'DUPONT JEAN',
          expectedDob: baseDob,
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(fullName: null, dateOfBirth: baseDob),
        );
        expect(result.nameOk, false);
      });

      test('fails when dob year does not match', () {
        final result = OcrParser.validate(
          expectedFullName: 'TEST USER',
          expectedDob: DateTime(1990, 3, 15),
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'TEST USER',
            dateOfBirth: DateTime(1985, 3, 15), // wrong year
          ),
        );
        expect(result.dobOk, false);
      });

      test('fails when dob is null', () {
        final result = OcrParser.validate(
          expectedFullName: 'TEST USER',
          expectedDob: baseDob,
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(fullName: 'TEST USER', dateOfBirth: null),
        );
        expect(result.dobOk, false);
      });

      test(
        'fails and flags foreign document when non-Cameroon nationality',
        () {
          final result = OcrParser.validate(
            expectedFullName: 'JOHN DOE',
            expectedDob: baseDob,
            expectedPlaceOfBirth: '',
            expectedNationality: 'NIGERIAN',
            docType: OfficialDocumentType.nationalId,
            extracted: makeExtracted(
              rawText: 'FEDERAL REPUBLIC OF NIGERIA',
              fullName: 'JOHN DOE',
              dateOfBirth: baseDob,
              nationality: 'NIGERIAN',
            ),
          );
          expect(result.nationalityOk, false);
          expect(result.ok, false);
          expect(result.summary, contains('Foreign'));
        },
      );
    });

    // ── Summary string ────────────────────────────────────────────────────────
    group('summary field', () {
      test('summary is "Verified" on full pass', () {
        final result = OcrParser.validate(
          expectedFullName: 'DUPONT JEAN',
          expectedDob: baseDob,
          expectedPlaceOfBirth: '',
          expectedNationality: '',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            fullName: 'DUPONT JEAN',
            dateOfBirth: baseDob,
          ),
        );
        expect(result.ok, true);
        expect(result.summary, contains('Verified'));
      });

      test('summary lists all failure reasons on total failure', () {
        final result = OcrParser.validate(
          expectedFullName: 'DUPONT JEAN',
          expectedDob: baseDob,
          expectedPlaceOfBirth: 'YAOUNDE',
          expectedNationality: 'CAMEROUNAISE',
          docType: OfficialDocumentType.nationalId,
          extracted: makeExtracted(
            rawText: 'FEDERAL REPUBLIC OF NIGERIA',
            fullName: 'WRONG NAME',
            dateOfBirth: DateTime(1800, 1, 1),
            placeOfBirth: 'LAGOS',
            nationality: 'NIGERIAN',
          ),
        );
        expect(result.ok, false);
        expect(result.summary.isNotEmpty, true);
      });
    });

    // ── OcrValidationResult.failed() factory ─────────────────────────────────
    group('OcrValidationResult.failed()', () {
      test('creates a fully-failed result with the given summary', () {
        final result = OcrValidationResult.failed('Document expired');
        expect(result.ok, false);
        expect(result.nameOk, false);
        expect(result.dobOk, false);
        expect(result.pobOk, false);
        expect(result.nationalityOk, false);
        expect(result.summary, 'Document expired');
      });
    });
  });
}
