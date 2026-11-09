import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/payment_card.dart';

void main() {
  test('card JSON never exports or restores raw cardholder data', () {
    final card = PaymentCard(
      id: 'card-1',
      brand: 'Visa',
      last4: '0010',
      expMonth: 12,
      expYear: 2030,
      number: '4000000000000010',
      holderName: 'TEST USER',
      cvv: '123',
    );

    final json = card.toJson();
    final restored = PaymentCard.fromJson({
      ...json,
      'number': card.number,
      'holderName': card.holderName,
      'cvv': card.cvv,
    });

    expect(json, {
      'id': 'card-1',
      'brand': 'Visa',
      'last4': '0010',
      'expMonth': 12,
      'expYear': 2030,
    });
    expect(restored.number, isEmpty);
    expect(restored.holderName, isEmpty);
    expect(restored.cvv, isEmpty);
  });
}
