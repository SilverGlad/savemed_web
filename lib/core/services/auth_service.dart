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
  }) async {
    final response = await ApiClient.post('/users/register', {
      'NAME': name,
      'EMAIL': email,
      'PASSWORD': password,
      'USER_ROLE': 'pharmacy_admin',
      'CPF': cnpj.replaceAll(RegExp(r'\D'), ''),
      'PHONE_NUMBER': phone.replaceAll(RegExp(r'\D'), ''),
    });

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erro ao criar conta');
    }

    return jsonDecode(response.body);
  }
}
