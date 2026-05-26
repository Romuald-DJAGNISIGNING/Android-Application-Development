// test/unit/election_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:camvote/features/voter_portal/domain/election.dart';

void main() {
  // Helper: build a minimal valid Election
  Election makeElection({
    required DateTime opensAt,
    required DateTime closesAt,
    ElectionType type = ElectionType.presidential,
    List<Candidate> candidates = const [],
  }) {
    return Election(
      id: 'e001',
      type: type,
      title: 'Test Election',
      opensAt: opensAt,
      closesAt: closesAt,
      scopeLabel: 'Cameroon',
      candidates: candidates,
    );
  }

  final now = DateTime.now();

  // ── ElectionStatus computed property ─────────────────────────────────────
  group('Election.status', () {
    test('returns upcoming when current time is before opensAt', () {
      final election = makeElection(
        opensAt: now.add(const Duration(hours: 2)),
        closesAt: now.add(const Duration(hours: 10)),
      );
      expect(election.status, ElectionStatus.upcoming);
    });

    test('returns open when current time is between opensAt and closesAt', () {
      final election = makeElection(
        opensAt: now.subtract(const Duration(hours: 1)),
        closesAt: now.add(const Duration(hours: 5)),
      );
      expect(election.status, ElectionStatus.open);
    });

    test('returns closed when current time is after closesAt', () {
      final election = makeElection(
        opensAt: now.subtract(const Duration(hours: 10)),
        closesAt: now.subtract(const Duration(hours: 1)),
      );
      expect(election.status, ElectionStatus.closed);
    });
  });

  // ── timeUntilOpen / timeUntilClose ────────────────────────────────────────
  group('Election.timeUntilOpen', () {
    test('returns a positive duration when election has not opened yet', () {
      final election = makeElection(
        opensAt: now.add(const Duration(hours: 5)),
        closesAt: now.add(const Duration(hours: 12)),
      );
      expect(election.timeUntilOpen.isNegative, false);
    });

    test('returns a negative duration when election has already opened', () {
      final election = makeElection(
        opensAt: now.subtract(const Duration(hours: 3)),
        closesAt: now.add(const Duration(hours: 5)),
      );
      expect(election.timeUntilOpen.isNegative, true);
    });
  });

  group('Election.timeUntilClose', () {
    test('returns a positive duration when election is still open', () {
      final election = makeElection(
        opensAt: now.subtract(const Duration(hours: 1)),
        closesAt: now.add(const Duration(hours: 4)),
      );
      expect(election.timeUntilClose.isNegative, false);
    });

    test('returns a negative duration when election has closed', () {
      final election = makeElection(
        opensAt: now.subtract(const Duration(hours: 10)),
        closesAt: now.subtract(const Duration(hours: 2)),
      );
      expect(election.timeUntilClose.isNegative, true);
    });
  });

  // ── ElectionType coverage ─────────────────────────────────────────────────
  group('ElectionType', () {
    test('all 6 election types can be set on an Election', () {
      final types = [
        ElectionType.presidential,
        ElectionType.parliamentary,
        ElectionType.municipal,
        ElectionType.regional,
        ElectionType.senatorial,
        ElectionType.referendum,
      ];

      for (final type in types) {
        final election = makeElection(
          type: type,
          opensAt: now.add(const Duration(hours: 1)),
          closesAt: now.add(const Duration(hours: 5)),
        );
        expect(election.type, type);
      }
    });
  });

  // ── Candidate model ───────────────────────────────────────────────────────
  group('Candidate', () {
    test('stores all fields correctly', () {
      const candidate = Candidate(
        id: 'c001',
        fullName: 'John Fru Ndi',
        partyName: 'Social Democratic Front',
        partyAcronym: 'SDF',
      );

      expect(candidate.id, 'c001');
      expect(candidate.fullName, 'John Fru Ndi');
      expect(candidate.partyName, 'Social Democratic Front');
      expect(candidate.partyAcronym, 'SDF');
    });
  });

  // ── Election with candidates ──────────────────────────────────────────────
  group('Election.candidates', () {
    test('stores and retrieves candidates list', () {
      const candidates = [
        Candidate(
          id: 'c1',
          fullName: 'Candidate Alpha',
          partyName: 'Alpha Party',
          partyAcronym: 'AP',
        ),
        Candidate(
          id: 'c2',
          fullName: 'Candidate Beta',
          partyName: 'Beta Party',
          partyAcronym: 'BP',
        ),
      ];

      final election = makeElection(
        opensAt: now.add(const Duration(days: 1)),
        closesAt: now.add(const Duration(days: 2)),
        candidates: candidates,
      );

      expect(election.candidates.length, 2);
      expect(election.candidates[0].fullName, 'Candidate Alpha');
      expect(election.candidates[1].partyAcronym, 'BP');
    });

    test('optional fields default to null when not provided', () {
      final election = makeElection(
        opensAt: now.add(const Duration(days: 1)),
        closesAt: now.add(const Duration(days: 2)),
      );

      expect(election.registrationDeadline, isNull);
      expect(election.campaignStartsAt, isNull);
      expect(election.campaignEndsAt, isNull);
      expect(election.resultsPublishAt, isNull);
      expect(election.runoffOpensAt, isNull);
      expect(election.runoffClosesAt, isNull);
    });
  });
}
