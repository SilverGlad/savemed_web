import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/storage/token_storage.dart';
import '../../support/in_memory_token_vault.dart';

void main() {
  late InMemoryTokenVault vault;

  setUp(() {
    TokenStorage.resetForTesting();
    vault = InMemoryTokenVault();
    TokenStorage.setVaultForTesting(vault);
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'new tokens use the secure vault, not the legacy preference key',
    () async {
      await TokenStorage.saveToken('new-session-token');
      final prefs = await SharedPreferences.getInstance();

      expect(await TokenStorage.getToken(), 'new-session-token');
      expect(prefs.getString('auth_token'), isNull);
      expect(await vault.read(), 'new-session-token');
    },
  );

  test('migrates a legacy token once and removes its plaintext copy', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'legacy-token'});

    expect(await TokenStorage.getToken(), 'legacy-token');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
    expect(await vault.read(), 'legacy-token');
  });

  test(
    'secure token takes precedence and removes a stale legacy copy',
    () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'legacy-token'});
      await vault.write('secure-token');

      expect(await TokenStorage.getToken(), 'secure-token');
      expect(
        (await SharedPreferences.getInstance()).getString('auth_token'),
        isNull,
      );
    },
  );

  test('clearing removes secure and legacy token copies', () async {
    await TokenStorage.saveToken('session-token');
    final clearing = TokenStorage.clear();

    expect(await TokenStorage.getToken(), isNull);
    await clearing;

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
    expect(await vault.read(), isNull);
  });
}
