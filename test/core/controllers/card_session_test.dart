import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/card_controller.dart';
import 'package:savemed/core/storage/card_storage.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/models/payment_card.dart';
import '../../support/in_memory_token_vault.dart';

void main() {
  setUp(() async {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
    await CardStorage.clear();
  });
  for (final expired in [false, true]) {
    test(
      'session exit clears card controller and storage (expired: $expired)',
      () async {
        final cards = CardController();
        final auth = AuthController(cards: cards);
        addTearDown(cards.dispose);
        addTearDown(auth.dispose);
        await cards.addCard(_card());
        expect(cards.selected, isNotNull);
        final loading = cards.loadCards();
        if (expired) {
          await auth.expireSession();
        } else {
          await auth.logout();
        }
        await loading;
        expect(cards.cards, isEmpty);
        expect(cards.selected, isNull);
        expect(cards.loading, isFalse);
        expect(await CardStorage.load(), isEmpty);
      },
    );
  }
  test('save started before clear cannot repopulate session storage', () async {
    final saving = CardStorage.save([_card()]);
    final clearing = CardStorage.clear();
    await Future.wait([saving, clearing]);
    expect(await CardStorage.load(), isEmpty);
  });
  test(
    'clearing card controller prevents sensitive session data from reloading',
    () async {
      final cards = CardController();
      addTearDown(cards.dispose);
      await cards.addCard(_card());

      cards.clear();
      await cards.loadCards();

      expect(cards.cards, isEmpty);
      expect(cards.selected, isNull);
      expect(await CardStorage.load(), isEmpty);
    },
  );
  test('disposing card controller releases its in-memory card data', () async {
    final cards = CardController();
    await cards.addCard(_card());

    cards.dispose();

    expect(cards.cards, isEmpty);
    expect(cards.selected, isNull);
    expect(await CardStorage.load(), isEmpty);
  });
  test(
    'pending card addition cannot notify or restore after session clear',
    () async {
      final cards = CardController();
      addTearDown(cards.dispose);
      final saving = cards.addCard(_card());
      cards.clear();
      await CardStorage.clear();
      await saving;
      expect(cards.cards, isEmpty);
      expect(cards.selected, isNull);
      expect(await CardStorage.load(), isEmpty);
    },
  );
}

PaymentCard _card() => PaymentCard(
  id: 'isolated-card',
  brand: 'Visa',
  last4: '0010',
  expMonth: 12,
  expYear: 2030,
  number: '4000000000000010',
  holderName: 'TESTE',
  cvv: '123',
);
