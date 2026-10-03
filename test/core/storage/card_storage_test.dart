import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/storage/card_storage.dart';
import 'package:savemed/models/payment_card.dart';

void main() {
  test('removes legacy raw cards and never persists new PAN or CVV', () async {
    SharedPreferences.setMockInitialValues({'saved_payment_cards': 'legacy'});
    await CardStorage.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_payment_cards', 'legacy');
    expect(await CardStorage.load(), isEmpty);
    expect(prefs.containsKey('saved_payment_cards'), isFalse);
    final card = PaymentCard(
      id: 'test',
      brand: 'Visa',
      last4: '0010',
      expMonth: 12,
      expYear: 2030,
      number: '4000000000000010',
      holderName: 'TESTE',
      cvv: '123',
    );
    await CardStorage.save([card]);
    expect((await CardStorage.load()).single, same(card));
    expect(prefs.containsKey('saved_payment_cards'), isFalse);
    await CardStorage.clear();
    expect(await CardStorage.load(), isEmpty);
  });
}
