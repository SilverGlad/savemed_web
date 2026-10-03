import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/models/user.dart';

import '../../support/in_memory_token_vault.dart';

void main() {
  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(TokenStorage.resetForTesting);

  test(
    'normalizes account email but preserves the password verbatim',
    () async {
      final service = _CapturingAuthService();
      final controller = AuthController(service: service);

      await controller.login(
        '  Conta.QA@Example.com  ',
        '  senha com espaços  ',
        AddressController(),
      );
      await controller.register(
        isCustomer: true,
        name: 'Conta QA',
        email: '  Conta.QA@Example.com  ',
        password: '  senha com espaços  ',
        document: '12345678901',
        phone: '11999999999',
      );

      expect(service.loginEmail, 'conta.qa@example.com');
      expect(service.registerEmail, 'conta.qa@example.com');
      expect(service.loginPassword, '  senha com espaços  ');
      expect(service.registerPassword, '  senha com espaços  ');
      await controller.logout();
    },
  );
}

class _CapturingAuthService extends AuthService {
  String? loginEmail;
  String? loginPassword;
  String? registerEmail;
  String? registerPassword;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginEmail = email;
    loginPassword = password;
    return const AuthSession(
      token: 'test-token',
      user: AppUser(
        id: 1,
        name: 'Admin SaveMed',
        email: 'admin@example.com',
        role: UserRole.appAdmin,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    registerEmail = email;
    registerPassword = password;
    return {};
  }
}
