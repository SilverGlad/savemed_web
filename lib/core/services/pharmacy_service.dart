import '../api/api_client.dart';
import '../api/api_response.dart';
import '../../models/postal_address.dart';

class PharmacyService {
  Future<PostalAddress> getPharmacyAddress(int pharmacyId) async {
    final response = await ApiClient.get('/addresses/pharmacy/$pharmacyId');
    return PostalAddress.fromJson(
      ApiResponse.object(
        response,
        expectedStatusCodes: {200},
        fallback: 'Erro ao buscar endereço da farmácia',
      ),
    );
  }
}
