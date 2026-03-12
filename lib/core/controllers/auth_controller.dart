import 'package:flutter/material.dart';
import 'package:http/http.dart' as context show read;
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/address_controller.dart'
    show AddressController;
import '../services/auth_service.dart';
import '../storage/token_storage.dart';

class AuthController extends ChangeNotifier {
  final _service = AuthService();

  Map<String, dynamic>? user;
  String? token;
  bool loading = true;

  bool get isLogged => token != null;

  // =====================
  // INIT / RESTORE SESSION
  // =====================
  Future<void> restoreSession(BuildContext context) async {
    final savedToken = await TokenStorage.getToken();

    print('Saved token: $savedToken');

    if (savedToken != null) {
      token = savedToken;

      try {
        user = await _service.me();

        // 👇 CARREGA ENDEREÇOS AQUI
        final addressCtrl = context.read<AddressController>();
        await addressCtrl.load(user!['ID']);
      } catch (e) {
        print('Erro ao restaurar sessão: $e');
        token = null;
        user = null;
        await TokenStorage.clear();
      }
    }

    loading = false;
    notifyListeners();
  }

  // =====================
  // LOGIN
  // =====================
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    final result = await _service.login(email: email, password: password);

    token = result['token'];
    user = result['user'];

    final addressCtrl = context.read<AddressController>();
    await addressCtrl.load(user!['ID']);

    await TokenStorage.saveToken(token!);

    notifyListeners();
  }

  // =====================
  // REGISTRO
  // =====================
  Future<void> register({
    required bool isCustomer,
    required String name,
    required String email,
    required String password,
    required String document,
    required String phone,
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
      );
    }
  }

  // =====================
  // LOGOUT
  // =====================
  Future<void> logout() async {
    token = null;
    user = null;
    await TokenStorage.clear();
    notifyListeners();
  }
}
