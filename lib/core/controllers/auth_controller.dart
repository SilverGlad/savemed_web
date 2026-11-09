import 'package:flutter/material.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/card_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/controllers/payment_controller.dart';
import 'package:savemed/core/logging/app_logger.dart';
import 'package:savemed/models/user.dart';

import '../services/auth_service.dart';
import '../storage/token_storage.dart';
import '../storage/card_storage.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service;
  final CardController? _cards;
  final CartController? _cart;
  final OrderController? _orders;
  final PaymentController? _payments;
  AddressController? _addresses;

  AppUser? user;
  String? token;
  String? sessionRestoreError;
  bool sessionExpired = false;
  bool loading = true;
  bool _restoringSession = false;
  int _sessionGeneration = 0;

  AuthController({
    AuthService? service,
    CardController? cards,
    CartController? cart,
    OrderController? orders,
    PaymentController? payments,
  }) : _service = service ?? AuthService(),
       _cards = cards,
       _cart = cart,
       _orders = orders,
       _payments = payments {
    ApiClient.setUnauthorizedHandler(expireSession);
  }

  bool get isLogged => token != null && user != null;
  UserRole get role => user?.role ?? UserRole.unknown;
  bool get isAdmin => role.isAdmin;

  String _normalizeEmail(String value) => value.trim().toLowerCase();

  Future<void> restoreSession(AddressController addressController) async {
    _addresses = addressController;
    if (_restoringSession) return;
    final generation = ++_sessionGeneration;
    _restoringSession = true;

    final wasLoading = loading;
    loading = true;
    sessionRestoreError = null;
    if (!wasLoading) notifyListeners();

    try {
      _cards?.clearForSessionRestore();
      try {
        await CardStorage.clear();
      } catch (_) {
        AppLogger.event(AppLogEvent.cardDataCleanupFailed);
      }
      if (generation != _sessionGeneration) return;

      final savedToken = await TokenStorage.getToken();
      if (generation != _sessionGeneration) return;

      if (savedToken == null) {
        token = null;
        user = null;
        return;
      }

      token = savedToken;
      final restoredUser = await _service.me();
      if (generation != _sessionGeneration) return;
      user = restoredUser;
      await _loadAddresses(addressController);
    } on ApiResponseException catch (error) {
      if (generation != _sessionGeneration) return;
      token = null;
      user = null;

      if (error.isUnauthorized ||
          error.isForbidden ||
          error.statusCode == 404) {
        await TokenStorage.clear();
      } else {
        sessionRestoreError = _sessionRestoreFailureMessage;
      }
    } on ApiConnectionException {
      if (generation != _sessionGeneration) return;
      token = null;
      user = null;
      sessionRestoreError = _sessionRestoreFailureMessage;
    } catch (_) {
      if (generation != _sessionGeneration) return;
      token = null;
      user = null;
      sessionRestoreError = _sessionRestoreFailureMessage;
      AppLogger.event(AppLogEvent.sessionRestoreFailed);
    } finally {
      _restoringSession = false;
      if (generation == _sessionGeneration) {
        if (user == null) addressController.clear();
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> login(
    String email,
    String password,
    AddressController addressController,
  ) async {
    _addresses = addressController;
    final generation = ++_sessionGeneration;
    final result = await _service.login(
      email: _normalizeEmail(email),
      password: password,
    );
    if (generation != _sessionGeneration) return;

    _cards?.clear();
    _cart?.clear();
    _orders?.clear();
    _payments?.clear();
    await CardStorage.clear();
    if (generation != _sessionGeneration) return;

    token = result.token;
    user = result.user;
    sessionRestoreError = null;
    sessionExpired = false;

    await TokenStorage.saveToken(token!);
    if (generation != _sessionGeneration) return;
    await _loadAddresses(addressController);

    if (generation != _sessionGeneration) return;
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
    final normalizedEmail = _normalizeEmail(email);

    if (isCustomer) {
      await _service.registerCustomer(
        name: name,
        email: normalizedEmail,
        password: password,
        cpf: document,
        phone: phone,
      );
    } else {
      await _service.registerSeller(
        name: name,
        email: normalizedEmail,
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
    _sessionGeneration++;
    final tokenClear = TokenStorage.clear();
    _cards?.clear();
    _addresses?.clear();
    _cart?.clear();
    _orders?.clear();
    _payments?.clear();
    token = null;
    user = null;
    sessionRestoreError = null;
    sessionExpired = false;
    loading = false;
    notifyListeners();
    await Future.wait([CardStorage.clear(), tokenClear]);
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    final generation = _sessionGeneration;
    final userId = user?.id;
    if (!isLogged || userId == null) return false;

    final updatedUser = await _service.updateProfile(name: name, phone: phone);
    if (generation != _sessionGeneration || user?.id != userId || !isLogged) {
      return false;
    }
    user = updatedUser;
    notifyListeners();
    return true;
  }

  Future<void> expireSession() async {
    _sessionGeneration++;
    final tokenClear = TokenStorage.clear();
    _cards?.clear();
    _addresses?.clear();
    _cart?.clear();
    _orders?.clear();
    _payments?.clear();
    token = null;
    user = null;
    sessionRestoreError = null;
    sessionExpired = true;
    loading = false;
    notifyListeners();
    await Future.wait([CardStorage.clear(), tokenClear]);
  }

  Future<void> _loadAddresses(AddressController addressController) async {
    if (isAdmin) {
      addressController.clear();
      return;
    }

    final userId = user?.id;
    if (userId == null) return;

    try {
      await addressController.load(userId);
    } catch (_) {
      AppLogger.event(AppLogEvent.sessionAddressLoadFailed);
    }
  }

  static const _sessionRestoreFailureMessage =
      'Não foi possível validar sua sessão. Verifique sua conexão e tente novamente.';
}
