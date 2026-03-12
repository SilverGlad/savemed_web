import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';

class ShippingService {
  Future<List<Map<String, dynamic>>> quote({
    required String fromCep,
    required String toCep,
    required List<Map<String, dynamic>> products,
  }) async {
    final response = await ApiClient.post('/shipping/quote', {
      "from": {"postal_code": fromCep},
      "to": {"postal_code": toCep},
      "products": products,
    });

    final List data = jsonDecode(response.body);

    // só opções válidas (sem erro)
    return data
        .where((e) => e['price'] != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }
}
