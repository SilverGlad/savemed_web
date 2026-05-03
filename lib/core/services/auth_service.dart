import 'dart:convert';
import '../api/api_client.dart';

class AuthService {
  // =====================
  // LOGIN
  // =====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/users/login', {
      'EMAIL': email,
      'PASSWORD': password,
    });

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erro ao fazer login');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await ApiClient.get('/users/me');

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Token inválido');
    }

    return jsonDecode(response.body);
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await ApiClient.post('/users/forgot-password', {
      'EMAIL': email,
    });

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        data['error'] ?? 'Erro ao solicitar recuperação de senha',
      );
    }

    return (data['message'] ?? 'Código enviado com sucesso').toString();
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final response = await ApiClient.post('/users/reset-password', {
      'EMAIL': email,
      'CODE': code,
      'PASSWORD': password,
    });

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Erro ao redefinir senha');
    }

    return (data['message'] ?? 'Senha redefinida com sucesso').toString();
  }

  Future<List<dynamic>> listPharmacies() async {
    final response = await ApiClient.get('/pharmacies');

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erro ao buscar farmacias');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  // =====================
  // REGISTRO - CLIENTE
  // =====================
  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    final response = await ApiClient.post('/users/register', {
      'NAME': name,
      'EMAIL': email,
      'PASSWORD': password,
      'USER_ROLE': 'customer',
      'CPF': cpf.replaceAll(RegExp(r'\D'), ''),
      'PHONE_NUMBER': phone.replaceAll(RegExp(r'\D'), ''),
    });

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erro ao criar conta');
    }

    return jsonDecode(response.body);
  }

  // =====================
  // REGISTRO - VENDEDOR (CNPJ)
  // =====================
  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String email,
    required String password,
    required String cnpj,
    required String phone,
    required String pharmacyName,
    required String city,
    required String state,
    required String zipcode,
  }) async {
    final pharmacyResponse = await ApiClient.post('/pharmacies', {
      'NAME': pharmacyName,
      'CNPJ': cnpj.replaceAll(RegExp(r'\D'), ''),
      'PHONE': phone.replaceAll(RegExp(r'\D'), ''),
      'CITY': city.trim(),
      'STATE': state.trim(),
      'ZIPCODE': zipcode.replaceAll(RegExp(r'\D'), ''),
    });

    if (pharmacyResponse.statusCode != 201) {
      final data = jsonDecode(pharmacyResponse.body);
      throw Exception(data['error'] ?? 'Erro ao criar farmacia');
    }

    final pharmacyData =
        jsonDecode(pharmacyResponse.body) as Map<String, dynamic>;
    final pharmacyId = pharmacyData['ID'];

    final response = await ApiClient.post('/users/register', {
      'NAME': name,
      'EMAIL': email,
      'PASSWORD': password,
      'USER_ROLE': 'pharmacy_admin',
      'PHARMACY_ID': pharmacyId,
      'PHONE_NUMBER': phone.replaceAll(RegExp(r'\D'), ''),
    });

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erro ao criar conta');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> requestExistingPharmacyAccess({
    required String name,
    required String email,
    required String password,
    required String cnpj,
    required String phone,
    required int pharmacyId,
    String? requestMessage,
  }) async {
    final response =
        await ApiClient.post('/users/register/pharmacy-access-request', {
          'NAME': name,
          'EMAIL': email,
          'PASSWORD': password,
          'PHARMACY_ID': pharmacyId,
          'CPF': cnpj.replaceAll(RegExp(r'\D'), ''),
          'PHONE_NUMBER': phone.replaceAll(RegExp(r'\D'), ''),
          'REQUEST_MESSAGE': requestMessage?.trim(),
        });

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erro ao solicitar acesso');
    }

    return jsonDecode(response.body);
  }
}
