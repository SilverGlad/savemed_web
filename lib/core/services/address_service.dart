import '../api/api_client.dart';
import '../api/api_response.dart';

class AddressService {
  Future<List<dynamic>> getUserAddresses(int userId) async {
    final response = await ApiClient.get('/addresses/user/$userId');
    return ApiResponse.list(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar enderecos',
    );
  }

  Future<void> createAddress(Map<String, dynamic> data) async {
    final response = await ApiClient.post('/addresses', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {201},
      fallback: 'Erro ao criar endereco',
    );
  }

  Future<void> updateAddress(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put('/addresses/$id', data);
    ApiResponse.success(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao atualizar endereco',
    );
  }

  Future<void> deleteAddress(int id) async {
    final response = await ApiClient.delete('/addresses/$id');
    ApiResponse.success(
      response,
      expectedStatusCodes: {200, 204},
      fallback: 'Erro ao remover endereco',
    );
  }
}
