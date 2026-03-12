import 'dart:convert';
import '../api/api_client.dart';

class PharmacyService {
  Future<Map<String, dynamic>> getPharmacyAddress(int pharmacyId) async {
    final response = await ApiClient.get('/addresses/pharmacy/$pharmacyId');

    return jsonDecode(response.body);
  }
}
