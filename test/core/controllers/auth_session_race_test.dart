import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/card_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/models/payment_card.dart';
import 'package:savemed/core/storage/token_storage.dart';
import '../../support/in_memory_token_vault.dart';
import 'package:savemed/models/user.dart';

const _customer = AppUser(
  id: 1,
  name: 'Cliente SaveMed',
  email: 'cliente@example.com',
  role: UserRole.customer,
);

class _DelayedAuthService extends AuthService {
  final loginResult = Completer<AuthSession>();
  final userResult = Completer<AppUser>();
  final profileResult = Completer<AppUser>();
  final meStarted = Completer<void>();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => loginResult.future;

  @override
  Future<AppUser> me() {
    if (!meStarted.isCompleted) meStarted.complete();
    return userResult.future;
  }

  @override
  Future<AppUser> updateProfile({
    required String name,
    required String phone,
  }) => profileResult.future;
}

void main() {
  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'late login response after logout does not recreate the session',
    () async {
      final service = _DelayedAuthService();
      final auth = AuthController(service: service);
      final addresses = AddressController();

      final login = auth.login('cliente@example.com', 'password', addresses);
      final logout = auth.logout();
      expect(auth.isLogged, isFalse);
      await logout;
      service.loginResult.complete(
        const AuthSession(token: 'late-token', user: _customer),
      );
      await login;

      expect(auth.user, isNull);
      expect(auth.token, isNull);
      expect(auth.isLogged, isFalse);
      expect(await TokenStorage.getToken(), isNull);
    },
  );

  test(
    'session restore purges card data left by a legacy app version',
    () async {
      SharedPreferences.setMockInitialValues({
        'saved_payment_cards': '[{"number":"4000000000000010","cvv":"123"}]',
      });
      final cards = CardController();
      final card = PaymentCard(
        id: 'legacy',
        brand: 'Visa',
        last4: '0010',
        expMonth: 12,
        expYear: 2030,
        number: '4000000000000010',
        holderName: 'TESTE',
        cvv: '123',
      );
      cards
        ..cards.add(card)
        ..selected = card;
      var cardNotifications = 0;
      cards.addListener(() => cardNotifications++);
      final auth = AuthController(cards: cards);

      await auth.restoreSession(AddressController());

      expect(cards.cards, isEmpty);
      expect(cards.selected, isNull);
      expect(cardNotifications, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('saved_payment_cards'), isFalse);
    },
  );

  test(
    'late profile response after logout does not restore user details',
    () async {
      final service = _DelayedAuthService();
      final auth = AuthController(service: service)
        ..user = _customer
        ..token = 'current-token'
        ..loading = false;

      final update = auth.updateProfile(
        name: 'Nome atualizado',
        phone: '11999',
      );
      final logout = auth.logout();
      expect(auth.isLogged, isFalse);
      await logout;
      service.profileResult.complete(
        const AppUser(
          id: 1,
          name: 'Nome atualizado',
          email: 'cliente@example.com',
          role: UserRole.customer,
        ),
      );
      expect(await update, isFalse);

      expect(auth.user, isNull);
      expect(auth.token, isNull);
      expect(auth.isLogged, isFalse);
    },
  );

  test(
    'late session restore after logout does not resurrect the account',
    () async {
      final service = _DelayedAuthService();
      final auth = AuthController(service: service);
      final addresses = AddressController();
      await TokenStorage.saveToken('saved-token');

      final restore = auth.restoreSession(addresses);
      await service.meStarted.future;
      await auth.logout();
      service.userResult.complete(_customer);
      await restore;

      expect(auth.user, isNull);
      expect(auth.token, isNull);
      expect(auth.isLogged, isFalse);
      expect(auth.loading, isFalse);
      expect(await TokenStorage.getToken(), isNull);
    },
  );

  test('token is unavailable as soon as session clearing begins', () async {
    await TokenStorage.saveToken('saved-token');

    final clearing = TokenStorage.clear();
    expect(await TokenStorage.getToken(), isNull);
    await clearing;

    await TokenStorage.saveToken('new-session-token');
    expect(await TokenStorage.getToken(), 'new-session-token');
  });
}
