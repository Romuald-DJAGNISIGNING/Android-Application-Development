import 'package:camvote/features/support/models/tip_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TipStatusResult.toCheckoutSession', () {
    test(
      'restores Max It sessions even when only provider metadata is known',
      () {
        const result = TipStatusResult(
          tipId: 'tip_maxit_1',
          status: 'pending',
          provider: 'maxit_qr',
          amount: 5000,
          currency: 'XAF',
          senderName: 'Anonymous supporter',
          anonymous: true,
          orangeMoneyOwner: 'CamVote Support',
        );

        final session = result.toCheckoutSession();

        expect(session, isNotNull);
        expect(session!.provider, equals('maxit_qr'));
        expect(session.amount, equals(5000));
        expect(session.currency, equals('XAF'));
        expect(session.orangeMoneyOwner, equals('CamVote Support'));
      },
    );

    test('preserves checkout metadata for hosted providers', () {
      const result = TipStatusResult(
        tipId: 'tip_remitly_1',
        status: 'pending',
        provider: 'remitly',
        amount: 12000,
        currency: 'EUR',
        senderName: 'Supporter',
        checkoutUrl: 'https://www.remitly.com/?camvote_tip_id=tip_remitly_1',
        deepLink: 'remitly://send?tip_id=tip_remitly_1',
        orangeMoneyMaskedNumber: '+23769****17',
      );

      final session = result.toCheckoutSession();

      expect(session, isNotNull);
      expect(session!.checkoutUrl, contains('camvote_tip_id=tip_remitly_1'));
      expect(session.deepLink, equals('remitly://send?tip_id=tip_remitly_1'));
      expect(session.orangeMoneyMaskedNumber, equals('+23769****17'));
    });

    test(
      'returns null when no recovery metadata exists for hosted providers',
      () {
        const result = TipStatusResult(
          tipId: 'tip_taptap_1',
          status: 'pending',
          provider: 'taptap_send',
          amount: 0,
          currency: 'XAF',
          senderName: 'Supporter',
        );

        expect(result.toCheckoutSession(), isNull);
      },
    );
  });
}
