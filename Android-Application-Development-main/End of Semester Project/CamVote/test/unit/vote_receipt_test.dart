// test/unit/vote_receipt_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:camvote/features/voter_portal/domain/vote_receipt.dart';

void main() {
  group('VoteReceipt', () {
    final fixedTime = DateTime(2026, 5, 26, 10, 0, 0);

    VoteReceipt makeReceipt({String? id}) => VoteReceipt(
      id: id ?? 'receipt-001',
      electionId: 'election-2026',
      electionTitle: 'Presidential Election 2026',
      candidateHash: 'hash_abc123',
      partyHash: 'hash_party_xyz',
      auditToken: 'audit_tok_999',
      castAt: fixedTime,
    );

    // ── Constructor ──────────────────────────────────────────────────────────
    group('constructor', () {
      test('stores all fields correctly', () {
        final r = makeReceipt();
        expect(r.id, 'receipt-001');
        expect(r.electionId, 'election-2026');
        expect(r.electionTitle, 'Presidential Election 2026');
        expect(r.candidateHash, 'hash_abc123');
        expect(r.partyHash, 'hash_party_xyz');
        expect(r.auditToken, 'audit_tok_999');
        expect(r.castAt, fixedTime);
      });
    });

    // ── toJson ───────────────────────────────────────────────────────────────
    group('toJson()', () {
      test('serializes all fields correctly', () {
        final json = makeReceipt().toJson();

        expect(json['id'], 'receipt-001');
        expect(json['election_id'], 'election-2026');
        expect(json['election_title'], 'Presidential Election 2026');
        expect(json['candidate_hash'], 'hash_abc123');
        expect(json['party_hash'], 'hash_party_xyz');
        expect(json['audit_token'], 'audit_tok_999');
        expect(json['cast_at'], isA<String>());
        expect(json['cast_at'], fixedTime.toIso8601String());
      });

      test('cast_at is ISO 8601 formatted string', () {
        final json = makeReceipt().toJson();
        // Must be parseable back to a DateTime
        expect(
          () => DateTime.parse(json['cast_at'] as String),
          returnsNormally,
        );
      });
    });

    // ── fromJson ─────────────────────────────────────────────────────────────
    group('fromJson()', () {
      test('deserializes a complete JSON map correctly', () {
        final json = {
          'id': 'receipt-002',
          'election_id': 'election-2025',
          'election_title': 'Municipal Election',
          'candidate_hash': 'hash_def456',
          'party_hash': 'hash_ppp',
          'audit_token': 'tok_456',
          'cast_at': '2025-10-01T08:00:00.000',
        };

        final r = VoteReceipt.fromJson(json);

        expect(r.id, 'receipt-002');
        expect(r.electionId, 'election-2025');
        expect(r.electionTitle, 'Municipal Election');
        expect(r.candidateHash, 'hash_def456');
        expect(r.partyHash, 'hash_ppp');
        expect(r.auditToken, 'tok_456');
        expect(r.castAt.year, 2025);
        expect(r.castAt.month, 10);
        expect(r.castAt.day, 1);
      });

      test('uses empty strings for missing string fields', () {
        final r = VoteReceipt.fromJson({});
        expect(r.id, '');
        expect(r.electionId, '');
        expect(r.candidateHash, '');
        expect(r.auditToken, '');
      });

      test('falls back to DateTime.now() when cast_at is missing', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final r = VoteReceipt.fromJson({'cast_at': null});
        final after = DateTime.now().add(const Duration(seconds: 1));

        expect(r.castAt.isAfter(before), true);
        expect(r.castAt.isBefore(after), true);
      });

      test('falls back to DateTime.now() when cast_at is malformed', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final r = VoteReceipt.fromJson({'cast_at': 'NOT-A-DATE'});
        final after = DateTime.now().add(const Duration(seconds: 1));

        expect(r.castAt.isAfter(before), true);
        expect(r.castAt.isBefore(after), true);
      });
    });

    // ── Round-trip ───────────────────────────────────────────────────────────
    group('round-trip (toJson → fromJson)', () {
      test('all fields survive a toJson → fromJson round-trip', () {
        final original = makeReceipt(id: 'rt-001');
        final restored = VoteReceipt.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.electionId, original.electionId);
        expect(restored.electionTitle, original.electionTitle);
        expect(restored.candidateHash, original.candidateHash);
        expect(restored.partyHash, original.partyHash);
        expect(restored.auditToken, original.auditToken);
        expect(
          restored.castAt.toIso8601String(),
          original.castAt.toIso8601String(),
        );
      });
    });
  });
}
