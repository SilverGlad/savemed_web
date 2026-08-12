import '../api/api_client.dart';
import '../api/api_response.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/users/login', {
      'EMAIL': email,
      'PASSWORD': password,
    });
    return ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao fazer login',
    );
  }

  Future<Map<String, dynamic>> me() async {
    final response = await ApiClient.get('/users/me');
    return ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Token invalido',
    );
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await ApiClient.post('/users/forgot-password', {
      'EMAIL': email,
    });
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao solicitar recuperacao de senha',
    );
    return (data['message'] ?? 'Codigo enviado com sucesso').toString();
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
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao redefinir senha',
    );
    return (data['message'] ?? 'Senha redefinida com sucesso').toString();
  }

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
    return ApiResponse.object(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar conta',
    );
  }

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
      'STATE': state.trim().toUpperCase(),
      'ZIPCODE': zipcode.replaceAll(RegExp(r'\D'), ''),
    });
    final pharmacyData = ApiResponse.object(
      pharmacyResponse,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar farmacia',
    );
    final pharmacyId = pharmacyData['ID'];
    if (pharmacyId == null) throw Exception('Resposta invalida do servidor.');

    final response = await ApiClient.post('/users/register', {
      'NAME': name,
      'EMAIL': email,
      'PASSWORD': password,
      'USER_ROLE': 'pharmacy_admin',
      'PHARMACY_ID': pharmacyId,
      'PHONE_NUMBER': phone.replaceAll(RegExp(r'\D'), ''),
    });

    try {
      return ApiResponse.object(
        response,
        expectedStatusCodes: {201},
        fallback: 'Erro ao criar conta',
      );
    } catch (_) {
      try {
        await ApiClient.delete('/pharmacies/$pharmacyId');
      } catch (_) {
        // O backend deve oferecer criacao transacional para eliminar este fallback.
      }
      rethrow;
    }
  }
}
