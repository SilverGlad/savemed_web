import 'dart:convert';

import '../api/api_client.dart';

class AdminService {
  Future<List<dynamic>> listPharmacies() async {
    final res = await ApiClient.get('/pharmacies');
    return _decodeList(res, 'Erro ao buscar farmacias');
  }

  Future<void> savePharmacy(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/pharmacies', data)
        : await ApiClient.put('/pharmacies/$id', data);
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao salvar farmacia',
    );
  }

  Future<void> deletePharmacy(int id) async {
    final response = await ApiClient.delete('/pharmacies/$id');
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao remover farmacia',
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
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao salvar categoria',
    );
  }

  Future<void> deleteCategory(int id) async {
    final response = await ApiClient.delete('/categories/$id');
    _ensureSuccess(
      response.statusCode,
      response.body,
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
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao salvar medicamento',
    );
  }

  Future<void> deleteMedication(int id) async {
    final response = await ApiClient.delete('/medications/$id');
    _ensureSuccess(
      response.statusCode,
      response.body,
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
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao salvar item do inventario',
    );
  }

  Future<void> deleteInventory(int id) async {
    final response = await ApiClient.delete('/inventory/$id');
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao remover item do inventario',
    );
  }

  Future<List<dynamic>> listOrders({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/orders',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(res, 'Erro ao buscar pedidos');
  }

  Future<List<dynamic>> listAccessRequests({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/users/access-requests',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(res, 'Erro ao buscar solicitacoes');
  }

  Future<void> approveAccessRequest(int id) async {
    final response = await ApiClient.post(
      '/users/access-requests/$id/approve',
      {},
    );
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao aprovar solicitacao',
    );
  }

  Future<void> rejectAccessRequest(int id) async {
    final response = await ApiClient.post(
      '/users/access-requests/$id/reject',
      {},
    );
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao rejeitar solicitacao',
    );
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/orders/$id', data);
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao atualizar pedido',
    );
  }

  Future<void> refundOrder(int id) async {
    final response = await ApiClient.post('/orders/$id/refund', {});
    _ensureSuccess(
      response.statusCode,
      response.body,
      fallback: 'Erro ao estornar pedido',
    );
  }

  List<dynamic> _decodeList(dynamic response, String fallback) {
    if (response.statusCode != 200) {
      _ensureSuccess(response.statusCode, response.body, fallback: fallback);
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  void _ensureSuccess(int statusCode, String body, {required String fallback}) {
    if (statusCode >= 200 && statusCode < 300) return;

    String message = fallback;
    try {
      final data = jsonDecode(body);
      message = data['error']?.toString() ?? fallback;
    } catch (_) {}
    throw Exception(message);
  }
}
