import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../auth/user_role.dart';
import '../../models/pharmacy_access_request_summary.dart';
import '../../models/user.dart';
import '../../models/pharmacy.dart';
import '../../models/category.dart';
import '../../models/active_ingredient.dart';
import '../../models/medication.dart';
import '../../models/admin_inventory_item.dart';
import '../../models/promotion.dart';
import '../../models/customer_order.dart';
import '../../models/order_fulfillment.dart';
import '../../models/pharmacy_operation.dart';
import '../../models/content_block.dart';
import '../../models/financial_summary.dart';
import '../../models/subcategory.dart';

class AdminService {
  const AdminService();

  Future<List<ContentBlock>> listContentBlocks() async {
    final response = await ApiClient.get(
      '/content',
      query: {'includeInactive': 'true'},
    );
    return _decodeList(
      response,
      'Erro ao buscar conteúdos',
    ).whereType<Map<String, dynamic>>().map(ContentBlock.fromJson).toList();
  }

  Future<int> saveContentBlock(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/content', data)
        : await ApiClient.put('/content/$id', data);
    final object = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201},
      fallback: 'Erro ao salvar conteúdo',
    );
    return int.tryParse('${object['ID'] ?? object['id']}') ?? id ?? 0;
  }

  Future<void> uploadContentImage(
    int id, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await ApiClient.multipartPost(
      '/content/$id/upload',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao enviar imagem do conteúdo',
    );
  }

  Future<void> deleteContentBlock(int id) async {
    final response = await ApiClient.delete('/content/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao remover conteúdo',
    );
  }

  Future<FinancialSummary> getFinancialSummary({int? pharmacyId}) async {
    final response = await ApiClient.get(
      '/orders/financial-summary',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return FinancialSummary.fromJson(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Erro ao buscar resumo financeiro',
      ),
    );
  }

  Future<List<Pharmacy>> listPharmacies() async {
    final res = await ApiClient.get(
      '/pharmacies',
      query: {'includeInactive': 'true'},
    );
    return _decodeList(
      res,
      'Erro ao buscar farmácias',
    ).whereType<Map<String, dynamic>>().map(Pharmacy.fromJson).toList();
  }

  Future<int> savePharmacy(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/pharmacies', data)
        : await ApiClient.put('/pharmacies/$id', data);
    if (response.statusCode == 204 && id != null) return id;
    final result = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201},
      fallback: 'Erro ao salvar farmácia',
    );
    final value = result['ID'] ?? result['id'] ?? id;
    final pharmacyId = value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    if (pharmacyId == null) {
      throw Exception('Resposta inválida do servidor.');
    }
    return pharmacyId;
  }

  Future<void> uploadPharmacyImage(
    int id, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await ApiClient.multipartPost(
      '/pharmacies/$id/upload',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao enviar imagem da farmácia',
    );
  }

  Future<void> deletePharmacy(int id) async {
    final response = await ApiClient.delete('/pharmacies/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover farmácia',
    );
  }

  Future<void> deactivatePharmacy(int id, {required String reason}) async {
    final response = await ApiClient.put('/pharmacies/$id', {
      'IS_ACTIVE': false,
      'INACTIVE_REASON': reason,
    });
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao inativar farmácia',
    );
  }

  Future<List<AppUser>> listPharmacyUsers(int pharmacyId) async {
    final response = await ApiClient.get('/users/pharmacy/$pharmacyId');
    return _decodeList(
      response,
      'Erro ao buscar usuários da farmácia',
    ).whereType<Map<String, dynamic>>().map(AppUser.fromJson).toList();
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
      fallback: 'Erro ao criar usuário da farmácia',
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

  Future<void> updateUserStatus(int userId, {required bool isActive}) async {
    final response = await ApiClient.put('/users/$userId/status', {
      'IS_ACTIVE': isActive,
    });
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao alterar status do usuário',
    );
  }

  Future<List<Category>> listCategories({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/categories',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(
      res,
      'Erro ao buscar categorias',
    ).map(Category.fromJson).toList();
  }

  Future<int> saveCategory(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/categories', data)
        : await ApiClient.put('/categories/$id', data);
    final result = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar categoria',
    );
    final value = result['ID'] ?? result['id'] ?? id;
    final categoryId = value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    if (categoryId == null) throw Exception('Resposta inválida do servidor.');
    return categoryId;
  }

  Future<void> uploadCategoryImage(
    int categoryId, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await ApiClient.multipartPost(
      '/categories/$categoryId/upload',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao enviar ícone da categoria',
    );
  }

  Future<List<Subcategory>> listSubcategories(int categoryId) async {
    final response = await ApiClient.get(
      '/subcategories',
      query: {'category_id': '$categoryId'},
    );
    return _decodeList(response, 'Erro ao buscar subcategorias')
        .map(Subcategory.fromJson)
        .where((subcategory) => subcategory.categoryId == categoryId)
        .toList();
  }

  Future<int> saveSubcategory(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/subcategories', data)
        : await ApiClient.put('/subcategories/$id', data);
    final result = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201},
      fallback: 'Erro ao salvar subcategoria',
    );
    final value = result['ID'] ?? result['id'] ?? id;
    final subcategoryId = value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    if (subcategoryId == null) {
      throw Exception('Resposta inválida do servidor.');
    }
    return subcategoryId;
  }

  Future<void> deleteSubcategory(int id) async {
    final response = await ApiClient.delete('/subcategories/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao remover subcategoria',
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

  Future<String> invitePharmacyUser({
    required int pharmacyId,
    required String name,
    required String email,
    required UserRole role,
    String? phone,
  }) async {
    final response = await ApiClient.post('/users/invitations', {
      'NAME': name,
      'EMAIL': email,
      'USER_ROLE': role.apiValue,
      'PHARMACY_ID': pharmacyId,
      'PHONE_NUMBER': phone,
    });
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao enviar convite',
    );
    return data['message']?.toString() ?? 'Convite enviado com sucesso.';
  }

  Future<void> resendUserInvitation(int userId) async {
    final response = await ApiClient.post('/users/$userId/invitation', {});
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao reenviar convite',
    );
  }

  Future<List<PharmacyAccessRequestSummary>> listAccessRequests({
    String? query,
    PharmacyAccessRequestStatus? status,
    int? pharmacyId,
    DateTime? from,
    DateTime? to,
  }) async {
    final parameters = <String, String>{
      if (query?.trim().isNotEmpty == true) 'q': query!.trim(),
      if (status != null) 'status': status.apiValue,
      if (pharmacyId != null) 'pharmacyId': '$pharmacyId',
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
    };
    final suffix = parameters.isEmpty
        ? ''
        : '?${Uri(queryParameters: parameters).query}';
    final response = await ApiClient.get('/access-requests$suffix');
    final data = ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar solicitações',
    );
    return data
        .whereType<Map<String, dynamic>>()
        .map(PharmacyAccessRequestSummary.fromJson)
        .toList();
  }

  Future<String> approveAccessRequest(int id, {String? reason}) async {
    final response = await ApiClient.post('/access-requests/$id/approve', {
      'reason': reason?.trim(),
    });
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao aprovar solicitação',
    );
    return data['message']?.toString() ?? 'Solicitação aprovada.';
  }

  Future<String> rejectAccessRequest(int id, {required String reason}) async {
    final response = await ApiClient.post('/access-requests/$id/reject', {
      'reason': reason.trim(),
    });
    final data = ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao rejeitar solicitação',
    );
    return data['message']?.toString() ?? 'Solicitação rejeitada.';
  }

  Future<List<ActiveIngredient>> listActiveIngredients({
    int? pharmacyId,
  }) async {
    final response = await ApiClient.get(
      '/active-ingredients',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(
      response,
      'Erro ao buscar princípios ativos',
    ).map(ActiveIngredient.fromJson).toList();
  }

  Future<int> saveActiveIngredient(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/active-ingredients', data)
        : await ApiClient.put('/active-ingredients/$id', data);
    final result = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201},
      fallback: 'Erro ao salvar princípio ativo',
    );
    final value = result['ID'] ?? result['id'] ?? id;
    final ingredientId = value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    if (ingredientId == null) {
      throw Exception('Resposta inválida do servidor.');
    }
    return ingredientId;
  }

  Future<void> deleteActiveIngredient(int id) async {
    final response = await ApiClient.delete('/active-ingredients/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao remover princípio ativo',
    );
  }

  Future<List<Medication>> listMedications({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/medications',
      query: {
        'imageUrls': 'true',
        if (pharmacyId != null) 'pharmacyId': '$pharmacyId',
      },
    );
    return _decodeList(
      res,
      'Erro ao buscar medicamentos',
    ).map(Medication.fromJson).toList();
  }

  Future<int> saveMedication(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/medications', data)
        : await ApiClient.put('/medications/$id', data);
    final result = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar medicamento',
    );
    final resultId = result['ID'];
    final parsedId = resultId is int
        ? resultId
        : int.tryParse(resultId?.toString() ?? '');
    if (parsedId == null) throw Exception('Resposta inválida do servidor.');
    return parsedId;
  }

  Future<void> uploadMedicationImage(
    int medicationId, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await ApiClient.multipartPost(
      '/medications/$medicationId/upload',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao enviar imagem do produto',
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

  Future<List<AdminInventoryItem>> listInventory({int? pharmacyId}) async {
    final res = pharmacyId == null
        ? await ApiClient.get('/inventory')
        : await ApiClient.get('/inventory/pharmacy/$pharmacyId');
    return _decodeList(
      res,
      'Erro ao buscar inventário',
    ).map(AdminInventoryItem.fromJson).toList();
  }

  Future<void> saveInventory(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/inventory', data)
        : await ApiClient.put('/inventory/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar item do inventário',
    );
  }

  Future<void> deleteInventory(int id) async {
    final response = await ApiClient.delete('/inventory/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover item do inventário',
    );
  }

  Future<List<Promotion>> listHighlights({int? pharmacyId}) async {
    final response = await ApiClient.get(
      pharmacyId == null ? '/highlights' : '/highlights/pharmacy/$pharmacyId',
    );
    return _decodeList(
      response,
      'Erro ao buscar promoções',
    ).map(Promotion.fromJson).toList();
  }

  Future<int> saveHighlight(Map<String, dynamic> data, {int? id}) async {
    final response = id == null
        ? await ApiClient.post('/highlights', data)
        : await ApiClient.put('/highlights/$id', data);
    final result = ApiResponse.object(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao salvar promoção',
    );
    final resultId = result['ID'];
    final parsedId = resultId is int
        ? resultId
        : int.tryParse(resultId?.toString() ?? '');
    if (parsedId == null) throw Exception('Resposta inválida do servidor.');
    return parsedId;
  }

  Future<void> uploadHighlightImage(
    int highlightId, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await ApiClient.multipartPost(
      '/highlights/$highlightId/upload',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao enviar imagem da promoção',
    );
  }

  Future<void> deleteHighlight(int id) async {
    final response = await ApiClient.delete('/highlights/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao remover promoção',
    );
  }

  Future<List<CustomerOrder>> listOrders({int? pharmacyId}) async {
    final res = await ApiClient.get(
      '/orders',
      query: pharmacyId == null ? null : {'pharmacyId': '$pharmacyId'},
    );
    return _decodeList(
      res,
      'Erro ao buscar pedidos',
    ).map(CustomerOrder.fromJson).toList();
  }

  Future<OrderFulfillment> orderFulfillment(int id) async {
    final response = await ApiClient.get('/orders/$id/fulfillment');
    return OrderFulfillment(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Erro ao carregar o pedido',
      ),
    );
  }

  Future<PharmacyOperation> pharmacyOperation(int id) async =>
      PharmacyOperation.fromJson(
        ApiResponse.object(
          await ApiClient.get('/pharmacies/$id/operation'),
          expectedStatusCodes: {200},
          fallback: 'Não foi possível consultar a loja.',
        ),
      );

  Future<PharmacyOperation> updatePharmacyOperation(
    int id,
    int version,
    Map<String, dynamic> values,
  ) async => PharmacyOperation.fromJson(
    ApiResponse.object(
      await ApiClient.put('/pharmacies/$id/operation', {
        ...values,
        'version': version,
      }),
      expectedStatusCodes: {200},
      fallback: 'Não foi possível atualizar a loja.',
    ),
  );

  Future<OrderFulfillment> actOnOrder(
    int id,
    int version,
    String action, [
    Map<String, dynamic> details = const {},
  ]) async {
    final response = await ApiClient.post('/orders/$id/fulfillment', {
      ...details,
      'version': version,
      'action': action,
    });
    return OrderFulfillment(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Erro ao atualizar o pedido',
      ),
    );
  }

  Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/orders/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao atualizar pedido',
    );
  }

  Future<void> refundOrder(int id, {required String reason}) async {
    final response = await ApiClient.post('/orders/$id/refund', {
      'reason': reason.trim(),
    });
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 201, 204},
      fallback: 'Erro ao estornar pedido',
    );
  }

  List<Map<String, dynamic>> _decodeList(
    http.Response response,
    String fallback,
  ) {
    return ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: fallback,
    ).whereType<Map<String, dynamic>>().toList();
  }
}
