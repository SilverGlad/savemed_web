import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../auth/user_role.dart';

class AdminService {
  Future<List<dynamic>> listPharmacies() async {
    final res = await ApiClient.get(
      '/pharmacies',
      query: {'includeInactive': 'true'},
    );
    return _decodeList(res, 'Erro ao buscar farmacias');
  }

  Future<void> savePharmacy(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/pharmacies', data)
        : await ApiClient.put('/pharmacies/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar farmacia',
    );
  }

  Future<void> deletePharmacy(int id) async {
    final response = await ApiClient.delete('/pharmacies/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover farmacia',
    );
  }

  Future<List<dynamic>> listPharmacyUsers(int pharmacyId) async {
    final response = await ApiClient.get('/users/pharmacy/$pharmacyId');
    return _decodeList(response, 'Erro ao buscar usuarios da farmacia');
  }

  Future<void> createPharmacyUser({
    required int pharmacyId,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
  }) async {
    final response = await ApiClient.post('/users/register', {
      'NAME': name,
      'EMAIL': email,
      'PASSWORD': password,
      'USER_ROLE': role.apiValue,
      'PHARMACY_ID': pharmacyId,
      'PHONE_NUMBER': phone,
    });
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao criar usuario da farmacia',
    );
  }

  Future<void> resetUserPassword(int userId, String password) async {
    final response = await ApiClient.post(
      '/users/$userId/admin-reset-password',
      {'PASSWORD': password},
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao redefinir senha',
    );
  }

  Future<List<dynamic>> listCategories({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/categories',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(res, 'Erro ao buscar categorias');
  }

  Future<void> saveCategory(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/categories', data)
        : await ApiClient.put('/categories/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar categoria',
    );
  }

  Future<void> deleteCategory(int id) async {
    final response = await ApiClient.delete('/categories/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover categoria',
    );
  }

  Future<List<dynamic>> listMedications({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/medications',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(res, 'Erro ao buscar medicamentos');
  }

  Future<void> saveMedication(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/medications', data)
        : await ApiClient.put('/medications/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar medicamento',
    );
  }

  Future<void> deleteMedication(int id) async {
    final response = await ApiClient.delete('/medications/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover medicamento',
    );
  }

  Future<List<dynamic>> listInventory({int? pharmacyId}) async {
    final res = pharmacyId == null
        ? await ApiClient.get('/inventory')
        : await ApiClient.get('/inventory/pharmacy/$pharmacyId');
    return _decodeList(res, 'Erro ao buscar inventario');
  }

  Future<void> saveInventory(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/inventory', data)
        : await ApiClient.put('/inventory/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar item do inventario',
    );
  }

  Future<void> deleteInventory(int id) async {
    final response = await ApiClient.delete('/inventory/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover item do inventario',
    );
  }

  Future<List<dynamic>> listHighlights({int? pharmacyId}) async {
    final response = await ApiClient.get(
      pharmacyId == null ? '/highlights' : '/highlights/pharmacy/$pharmacyId',
    );
    return _decodeList(response, 'Erro ao buscar promocoes');
  }

  Future<void> saveHighlight(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/highlights', data)
        : await ApiClient.put('/highlights/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar promocao',
    );
  }

  Future<void> deleteHighlight(int id) async {
    final response = await ApiClient.delete('/highlights/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover promocao',
    );
  }

  Future<List<dynamic>> listOrders({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/orders',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(res, 'Erro ao buscar pedidos');
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/orders/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao atualizar pedido',
    );
  }

  Future<void> refundOrder(int id) async {
    final response = await ApiClient.post('/orders/$id/refund', {});
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao estornar pedido',
    );
  }

  List<dynamic> _decodeList(http.Response response, String fallback) {
    return ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: fallback,
    );
  }
}
