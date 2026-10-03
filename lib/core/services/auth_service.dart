import '../api/api_client.dart';
import '../api/api_response.dart';
import '../../models/pharmacy_registration_request.dart';
import '../../models/pharmacy_access_request.dart';
import '../../models/pharmacy_search_result.dart';
import '../../models/user.dart';

class AuthService {
  const AuthService();

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/users/login', {
      'EMAIL': email,
      'PASSWORD': password,
    });
    return AuthSession.fromJson(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Erro ao fazer login',
      ),
    );
  }

  Future<AppUser> me() async {
    final response = await ApiClient.get('/users/me');
    return AppUser.fromJson(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Token inválido',
      ),
    );
  }

  Future<AppUser> updateProfile({
    required String name,
    required String phone,
  }) async {
    final response = await ApiClient.put('/users/me', {
      'NAME': name.trim(),
      'PHONE_NUMBER': phone.replaceAll(RegExp(r'\D'), ''),
    });
    return AppUser.fromJson(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Não foi possível salvar seus dados.',
      ),
    );
  }

  Future<String> forgotPassword({required String email}) async {
    final response = await ApiClient.post('/users/forgot-password', {
      'EMAIL': email,
    });
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao solicitar recuperação de senha',
    );
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
    final request = PharmacyRegistrationRequest(
      administratorName: name,
      email: email,
      password: password,
      cnpj: cnpj,
      phone: phone,
      pharmacyName: pharmacyName,
      city: city,
      state: state,
      zipcode: zipcode,
    );
    final response = await ApiClient.post(
      '/pharmacies/register',
      request.toJson(),
    );
    return ApiResponse.object(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar conta da farmácia',
    );
  }

  Future<List<PharmacySearchResult>> searchPharmaciesForAccess(
    String query,
  ) async {
    final response = await ApiClient.get(
      '/access-requests/pharmacies?q=${Uri.encodeQueryComponent(query.trim())}',
    );
    final data = ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar farmácias',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map(PharmacySearchResult.fromJson)
        .toList();
  }

  Future<String> requestPharmacyAccess(PharmacyAccessRequest request) async {
    final response = await ApiClient.post('/access-requests', request.toJson());
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao solicitar acesso',
    );
    return data['message']?.toString() ?? 'Solicitação enviada com sucesso.';
  }
}
