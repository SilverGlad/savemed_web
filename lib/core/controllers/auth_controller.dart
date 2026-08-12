import 'package:flutter/material.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/controllers/address_controller.dart';

import '../services/auth_service.dart';
import '../storage/token_storage.dart';

class AuthController extends ChangeNotifier {
  final _service = AuthService();

  Map<String, dynamic>? user;
  String? token;
  bool loading = true;

  AuthController() {
    ApiClient.setUnauthorizedHandler(_expireSession);
  }

  bool get isLogged => token != null;
  UserRole get role => UserRole.fromApi(user?['USER_ROLE']);
  bool get isAdmin => role.isAdmin;

  Future<void> restoreSession(AddressController addressController) async {
    try {
      final savedToken = await TokenStorage.getToken();

      if (savedToken != null) {
        token = savedToken;
        user = await _service.me();
        if (!isAdmin) {
          await addressController.load(user!['ID']);
        }
      }
    } catch (e) {
      debugPrint('Nao foi possivel restaurar a sessao.');
      token = null;
      user = null;
      await TokenStorage.clear();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(
    String email,
    String password,
    AddressController addressController,
  ) async {
    final result = await _service.login(email: email, password: password);

    token = result['token'];
    user = result['user'];

    await TokenStorage.saveToken(token!);
    if (!isAdmin) {
      await addressController.load(user!['ID']);
    }

    notifyListeners();
  }

  Future<void> register({
    required bool isCustomer,
    required String name,
    required String email,
    required String password,
    required String document,
    required String phone,
    String? pharmacyName,
    String? city,
    String? state,
    String? zipcode,
  }) async {
    if (isCustomer) {
      await _service.registerCustomer(
        name: name,
        email: email,
        password: password,
        cpf: document,
        phone: phone,
      );
    } else {
      await _service.registerSeller(
        name: name,
        email: email,
        password: password,
        cnpj: document,
        phone: phone,
        pharmacyName: pharmacyName!,
        city: city!,
        state: state!,
        zipcode: zipcode!,
      );
    }
  }

  Future<void> logout() async {
    token = null;
    user = null;
    await TokenStorage.clear();
    notifyListeners();
  }

  Future<void> _expireSession() async {
    token = null;
    user = null;
    await TokenStorage.clear();
    notifyListeners();
  }
}
