import '../api/api_client.dart';
import '../api/api_response.dart';
import '../../models/postal_address.dart';

class AddressService {
  Future<List<PostalAddress>> getUserAddresses(int userId) async {
    final response = await ApiClient.get('/addresses/user/$userId');
    return ApiResponse.objects(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar endereços',
    ).map(PostalAddress.fromJson).toList(growable: false);
  }

  Future<void> createAddress(PostalAddress address) async {
    final response = await ApiClient.post(
      '/addresses',
      address.toRequestJson(),
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar endereço',
    );
  }

  Future<void> updateAddress(int id, PostalAddress address) async {
    final response = await ApiClient.put(
      '/addresses/$id',
      address.toRequestJson(),
    );
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao atualizar endereço',
    );
  }

  Future<void> deleteAddress(int id) async {
    final response = await ApiClient.delete('/addresses/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 204},
      fallback: 'Erro ao remover endereço',
    );
  }
}
