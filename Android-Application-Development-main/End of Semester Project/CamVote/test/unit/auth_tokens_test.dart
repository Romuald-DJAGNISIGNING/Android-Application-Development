// test/unit/auth_tokens_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:camvote/features/auth/models/auth_tokens.dart';

void main() {
  group('AuthTokens', () {
    final fixedExpiry = DateTime(2026, 12, 31, 23, 59, 59);

    // ── Constructor ──────────────────────────────────────────────────────────
    group('constructor', () {
      test('stores all fields correctly', () {
        final tokens = AuthTokens(
          accessToken: 'acc_token_123',
          refreshToken: 'ref_token_456',
          expiresAt: fixedExpiry,
        );

        expect(tokens.accessToken, 'acc_token_123');
        expect(tokens.refreshToken, 'ref_token_456');
        expect(tokens.expiresAt, fixedExpiry);
      });

      test('expiresAt can be null', () {
        final tokens = AuthTokens(
          accessToken: 'acc',
          refreshToken: 'ref',
          expiresAt: null,
        );
        expect(tokens.expiresAt, isNull);
      });
    });

    // ── fromJson ─────────────────────────────────────────────────────────────
    group('fromJson()', () {
      test('deserializes a full JSON map correctly', () {
        final json = {
          'access_token': 'acc_abc',
          'refresh_token': 'ref_xyz',
          'expires_at': fixedExpiry.toIso8601String(),
        };

        final tokens = AuthTokens.fromJson(json);

        expect(tokens.accessToken, 'acc_abc');
        expect(tokens.refreshToken, 'ref_xyz');
        expect(tokens.expiresAt, isNotNull);
        expect(tokens.expiresAt!.year, 2026);
        expect(tokens.expiresAt!.month, 12);
        expect(tokens.expiresAt!.day, 31);
      });

      test('uses empty string when access_token is missing', () {
        final tokens = AuthTokens.fromJson({});
        expect(tokens.accessToken, '');
      });

      test('uses empty string when refresh_token is missing', () {
        final tokens = AuthTokens.fromJson({});
        expect(tokens.refreshToken, '');
      });

      test('sets expiresAt to null when expires_at field is absent', () {
        final tokens = AuthTokens.fromJson({
          'access_token': 'acc',
          'refresh_token': 'ref',
        });
        expect(tokens.expiresAt, isNull);
      });

      test('sets expiresAt to null when expires_at is not a string', () {
        final tokens = AuthTokens.fromJson({
          'access_token': 'acc',
          'refresh_token': 'ref',
          'expires_at': 9999999, // wrong type
        });
        expect(tokens.expiresAt, isNull);
      });

      test('sets expiresAt to null when expires_at is null', () {
        final tokens = AuthTokens.fromJson({
          'access_token': 'acc',
          'refresh_token': 'ref',
          'expires_at': null,
        });
        expect(tokens.expiresAt, isNull);
      });
    });

    // ── toJson ───────────────────────────────────────────────────────────────
    group('toJson()', () {
      test('serializes a full token set correctly', () {
        final tokens = AuthTokens(
          accessToken: 'acc_tok',
          refreshToken: 'ref_tok',
          expiresAt: fixedExpiry,
        );

        final json = tokens.toJson();

        expect(json['access_token'], 'acc_tok');
        expect(json['refresh_token'], 'ref_tok');
        expect(json['expires_at'], fixedExpiry.toIso8601String());
      });

      test('serializes null expiresAt as null in JSON', () {
        final tokens = AuthTokens(
          accessToken: 'acc',
          refreshToken: 'ref',
          expiresAt: null,
        );

        final json = tokens.toJson();
        expect(json['expires_at'], isNull);
      });
    });

    // ── Round-trip ───────────────────────────────────────────────────────────
    group('round-trip (toJson → fromJson)', () {
      test('all fields survive with a valid expiresAt', () {
        final original = AuthTokens(
          accessToken: 'round_trip_acc',
          refreshToken: 'round_trip_ref',
          expiresAt: fixedExpiry,
        );

        final restored = AuthTokens.fromJson(original.toJson());

        expect(restored.accessToken, original.accessToken);
        expect(restored.refreshToken, original.refreshToken);
        expect(
          restored.expiresAt?.toIso8601String(),
          original.expiresAt?.toIso8601String(),
        );
      });

      test('all fields survive with null expiresAt', () {
        final original = AuthTokens(
          accessToken: 'acc',
          refreshToken: 'ref',
          expiresAt: null,
        );

        final restored = AuthTokens.fromJson(original.toJson());

        expect(restored.accessToken, original.accessToken);
        expect(restored.refreshToken, original.refreshToken);
        expect(restored.expiresAt, isNull);
      });
    });
  });
}
