import '../api/api_client.dart';
import '../api/api_response.dart';

class PharmacyService {
  Future<Map<String, dynamic>> getPharmacyAddress(int pharmacyId) async {
    final response = await ApiClient.get('/addresses/pharmacy/$pharmacyId');
    return ApiResponse.object(
      response,
      expectedStatusCodes: {200},
      fallback: 'Erro ao buscar endereco da farmacia',
    );
  }
}
