// test/unit/registration_identity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:camvote/features/registration/domain/registration_identity.dart';

void main() {
  group('RegistrationIdentity', () {
    final fixedDob = DateTime(1990, 7, 14);

    RegistrationIdentity makeIdentity() => RegistrationIdentity(
      fullName: 'Jean Dupont',
      dateOfBirth: fixedDob,
      placeOfBirth: 'Yaoundé',
      nationality: 'Cameroonian',
    );

    // ── Constructor ──────────────────────────────────────────────────────────
    group('constructor', () {
      test('stores all fields correctly', () {
        final id = makeIdentity();
        expect(id.fullName, 'Jean Dupont');
        expect(id.dateOfBirth, fixedDob);
        expect(id.placeOfBirth, 'Yaoundé');
        expect(id.nationality, 'Cameroonian');
      });
    });

    // ── toMap ────────────────────────────────────────────────────────────────
    group('toMap()', () {
      test('serializes all fields correctly', () {
        final map = makeIdentity().toMap();

        expect(map['fullName'], 'Jean Dupont');
        expect(map['placeOfBirth'], 'Yaoundé');
        expect(map['nationality'], 'Cameroonian');
        expect(map['dateOfBirth'], isA<String>());
        expect(map['dateOfBirth'], fixedDob.toIso8601String());
      });

      test('dateOfBirth is an ISO 8601 string parseable back to DateTime', () {
        final map = makeIdentity().toMap();
        expect(
          () => DateTime.parse(map['dateOfBirth'] as String),
          returnsNormally,
        );
        final parsed = DateTime.parse(map['dateOfBirth'] as String);
        expect(parsed.year, 1990);
        expect(parsed.month, 7);
        expect(parsed.day, 14);
      });
    });

    // ── fromMap ──────────────────────────────────────────────────────────────
    group('fromMap()', () {
      test('deserializes a complete map correctly', () {
        final map = {
          'fullName': 'Marie Ngono',
          'dateOfBirth': DateTime(1985, 3, 22).toIso8601String(),
          'placeOfBirth': 'Douala',
          'nationality': 'Cameroonian',
        };

        final id = RegistrationIdentity.fromMap(map);

        expect(id.fullName, 'Marie Ngono');
        expect(id.placeOfBirth, 'Douala');
        expect(id.nationality, 'Cameroonian');
        expect(id.dateOfBirth.year, 1985);
        expect(id.dateOfBirth.month, 3);
        expect(id.dateOfBirth.day, 22);
      });

      test('uses empty string for missing fullName', () {
        final id = RegistrationIdentity.fromMap({
          'dateOfBirth': DateTime(2000, 1, 1).toIso8601String(),
        });
        expect(id.fullName, '');
      });

      test('uses empty string for missing placeOfBirth', () {
        final id = RegistrationIdentity.fromMap({
          'dateOfBirth': DateTime(2000, 1, 1).toIso8601String(),
        });
        expect(id.placeOfBirth, '');
      });

      test('uses empty string for missing nationality', () {
        final id = RegistrationIdentity.fromMap({
          'dateOfBirth': DateTime(2000, 1, 1).toIso8601String(),
        });
        expect(id.nationality, '');
      });

      test('throws when dateOfBirth is missing (required field)', () {
        expect(
          () => RegistrationIdentity.fromMap({'fullName': 'Test'}),
          throwsA(anyOf(isA<Error>(), isA<Exception>())),
        );
      });
    });

    // ── Round-trip ───────────────────────────────────────────────────────────
    group('round-trip (toMap → fromMap)', () {
      test('all fields survive a toMap → fromMap round-trip', () {
        final original = makeIdentity();
        final restored = RegistrationIdentity.fromMap(original.toMap());

        expect(restored.fullName, original.fullName);
        expect(restored.placeOfBirth, original.placeOfBirth);
        expect(restored.nationality, original.nationality);
        expect(
          restored.dateOfBirth.toIso8601String(),
          original.dateOfBirth.toIso8601String(),
        );
      });
    });
  });
}
