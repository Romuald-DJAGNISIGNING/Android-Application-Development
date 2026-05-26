// test/unit/tip_input_constraints_test.dart
//
// Tests the pure sanitization and validation functions in tip_input_constraints.dart
// These functions have zero external dependencies — ideal for unit testing.

import 'package:flutter_test/flutter_test.dart';
import 'package:camvote/features/support/utils/tip_input_constraints.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // sanitizeTipMessage()
  // ═══════════════════════════════════════════════════════════════════════════
  group('sanitizeTipMessage()', () {
    test('returns the message unchanged when within the length limit', () {
      const msg = 'Thank you for building CamVote!';
      final result = sanitizeTipMessage(msg);
      expect(result, msg);
    });

    test('truncates message that exceeds the maximum length', () {
      final longMsg = 'A' * 10000;
      final result = sanitizeTipMessage(longMsg);
      expect(result.length, lessThanOrEqualTo(tipMaxMessageLength));
    });

    test('collapses multiple spaces into one', () {
      final result = sanitizeTipMessage('Hello   World');
      expect(result, 'Hello World');
    });

    test('strips control characters', () {
      // Null byte and other control chars should be replaced
      final result = sanitizeTipMessage('Hello\x00World');
      expect(result, isNot(contains('\x00')));
    });

    test('trims leading and trailing whitespace', () {
      final result = sanitizeTipMessage('  Hello World  ');
      expect(result, 'Hello World');
    });

    test('returns empty string for empty input', () {
      expect(sanitizeTipMessage(''), '');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // sanitizeTipName()
  // ═══════════════════════════════════════════════════════════════════════════
  group('sanitizeTipName()', () {
    test('returns "Anonymous supporter" when anonymous is true', () {
      final result = sanitizeTipName('Jean Dupont', anonymous: true);
      expect(result, 'Anonymous supporter');
    });

    test('returns the cleaned name when anonymous is false', () {
      final result = sanitizeTipName('Jean Dupont', anonymous: false);
      expect(result, 'Jean Dupont');
    });

    test('returns "Supporter" when non-anonymous name is empty', () {
      final result = sanitizeTipName('', anonymous: false);
      expect(result, 'Supporter');
    });

    test('returns "Supporter" when non-anonymous name is only spaces', () {
      final result = sanitizeTipName('   ', anonymous: false);
      expect(result, 'Supporter');
    });

    test('truncates a very long name to the sender name limit', () {
      final longName = 'A' * 5000;
      final result = sanitizeTipName(longName, anonymous: false);
      expect(result.length, lessThanOrEqualTo(tipMaxSenderNameLength));
    });

    test('ignores the real name when anonymous is true (privacy)', () {
      final result = sanitizeTipName('Romuald Djagnisigning', anonymous: true);
      expect(result, 'Anonymous supporter');
      expect(result, isNot(contains('Romuald')));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // sanitizeTipEmail()
  // ═══════════════════════════════════════════════════════════════════════════
  group('sanitizeTipEmail()', () {
    test('lowercases the email address', () {
      final result = sanitizeTipEmail('USER@EXAMPLE.COM');
      expect(result, 'user@example.com');
    });

    test('trims whitespace from the email', () {
      final result = sanitizeTipEmail('  user@example.com  ');
      expect(result, 'user@example.com');
    });

    test('returns empty string for empty input', () {
      expect(sanitizeTipEmail(''), '');
    });

    test('truncates emails longer than 254 characters', () {
      final longEmail = '${'a' * 250}@b.co';
      final result = sanitizeTipEmail(longEmail);
      expect(result.length, lessThanOrEqualTo(254));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // isValidTipEmail()
  // ═══════════════════════════════════════════════════════════════════════════
  group('isValidTipEmail()', () {
    test('returns true for a valid email address', () {
      expect(isValidTipEmail('user@example.com'), true);
    });

    test('returns true for an empty email (optional field)', () {
      expect(isValidTipEmail(''), true);
    });

    test('returns true for an email with subdomains', () {
      expect(isValidTipEmail('user@mail.example.co.uk'), true);
    });

    test('returns false for an email missing the @ symbol', () {
      expect(isValidTipEmail('notanemail.com'), false);
    });

    test('returns false for an email missing the domain', () {
      expect(isValidTipEmail('user@'), false);
    });

    test('returns false for an email missing the local part', () {
      expect(isValidTipEmail('@example.com'), false);
    });

    test('returns true for whitespace-only input (treated as empty)', () {
      expect(isValidTipEmail('   '), true);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // sanitizeTipReference()
  // ═══════════════════════════════════════════════════════════════════════════
  group('sanitizeTipReference()', () {
    test('uppercases the reference string', () {
      final result = sanitizeTipReference('ref-abc-123');
      expect(result, 'REF-ABC-123');
    });

    test('trims whitespace', () {
      final result = sanitizeTipReference('  REF123  ');
      expect(result, 'REF123');
    });

    test('truncates to the maximum reference length', () {
      final long = 'R' * 1000;
      final result = sanitizeTipReference(long);
      expect(result.length, lessThanOrEqualTo(tipMaxReferenceLength));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // sanitizeTipAttachmentUrls()
  // ═══════════════════════════════════════════════════════════════════════════
  group('sanitizeTipAttachmentUrls()', () {
    test('accepts a valid HTTPS URL', () {
      final result = sanitizeTipAttachmentUrls([
        'https://example.com/receipt.pdf',
      ]);
      expect(result, hasLength(1));
      expect(result.first, 'https://example.com/receipt.pdf');
    });

    test('accepts localhost HTTP URL', () {
      final result = sanitizeTipAttachmentUrls(['http://localhost:8080/file']);
      expect(result, hasLength(1));
    });

    test('removes duplicate URLs', () {
      final result = sanitizeTipAttachmentUrls([
        'https://example.com/file.pdf',
        'https://example.com/file.pdf',
      ]);
      expect(result, hasLength(1));
    });

    test('skips empty strings', () {
      final result = sanitizeTipAttachmentUrls(['', '  ']);
      expect(result, isEmpty);
    });

    test('throws ArgumentError for a non-HTTPS URL', () {
      expect(
        () => sanitizeTipAttachmentUrls(['http://example.com/file']),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for an invalid URL', () {
      expect(
        () => sanitizeTipAttachmentUrls(['not-a-url']),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when URL exceeds maximum length', () {
      final longUrl = 'https://example.com/${'a' * 5000}.pdf';
      expect(() => sanitizeTipAttachmentUrls([longUrl]), throwsArgumentError);
    });

    test(
      'throws ArgumentError when more than tipMaxAttachments are provided',
      () {
        final urls = List.generate(
          tipMaxAttachments + 1,
          (i) => 'https://example.com/file$i.pdf',
        );
        expect(() => sanitizeTipAttachmentUrls(urls), throwsArgumentError);
      },
    );

    test('returns empty list for empty input', () {
      expect(sanitizeTipAttachmentUrls([]), isEmpty);
    });
  });
}
