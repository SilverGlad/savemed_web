import 'dart:convert';
import '../api/api_client.dart';

class AddressService {
  Future<List<dynamic>> getUserAddresses(int userId) async {
    final res = await ApiClient.get('/addresses/user/$userId', query: {});

    if (res.statusCode != 200) {
      throw Exception('Erro ao buscar endereços');
    }

    return jsonDecode(res.body);
  }

  Future<void> createAddress(Map<String, dynamic> data) async {
    final res = await ApiClient.post('/addresses', data);

    if (res.statusCode != 201) {
      throw Exception('Erro ao criar endereço');
    }
  }

  Future<void> updateAddress(int id, Map<String, dynamic> data) async {
    final res = await ApiClient.put('/addresses/$id', data);

    if (res.statusCode != 200) {
      throw Exception('Erro ao atualizar endereço');
    }
  }

  Future<void> deleteAddress(int id) async {
    final res = await ApiClient.delete('/addresses/$id');

    if (res.statusCode != 200) {
      throw Exception('Erro ao remover endereço');
    }
  }
}
