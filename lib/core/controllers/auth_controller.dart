import 'package:flutter/material.dart';
import 'package:SaveMed/core/controllers/address_controller.dart';

import '../services/auth_service.dart';
import '../storage/token_storage.dart';

class AuthController extends ChangeNotifier {
  final _service = AuthService();

  Map<String, dynamic>? user;
  String? token;
  bool loading = true;

  bool get isLogged => token != null;

  Future<void> restoreSession(AddressController addressController) async {
    final savedToken = await TokenStorage.getToken();

    debugPrint('Saved token: $savedToken');

    if (savedToken != null) {
      token = savedToken;

      try {
        user = await _service.me();
        await addressController.load(user!['ID']);
      } catch (e) {
        debugPrint('Erro ao restaurar sessao: $e');
        token = null;
        user = null;
        await TokenStorage.clear();
      }
    }

    loading = false;
    notifyListeners();
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
    await addressController.load(user!['ID']);

    notifyListeners();
  }

  Future<void> register({
    required bool isCustomer,
    required String name,
    required String email,
    required String password,
    required String document,
    required String phone,
    bool useExistingPharmacy = false,
    int? pharmacyId,
    String? pharmacyName,
    String? city,
    String? state,
    String? zipcode,
    String? requestMessage,
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
      if (useExistingPharmacy) {
        await _service.requestExistingPharmacyAccess(
          name: name,
          email: email,
          password: password,
          cnpj: document,
          phone: phone,
          pharmacyId: pharmacyId!,
          requestMessage: requestMessage,
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
  }

  Future<void> logout() async {
    token = null;
    user = null;
    await TokenStorage.clear();
    notifyListeners();
  }
}
