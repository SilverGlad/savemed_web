import 'dart:convert';

import '../api/api_client.dart';

class ShippingQuoteException implements Exception {
  final String message;

  ShippingQuoteException(this.message);

  @override
  String toString() => message;
}

class ShippingService {
  Future<List<Map<String, dynamic>>> quote({
    required int pharmacyId,
    required String fromCep,
    required String toCep,
    required Map<String, dynamic> destinationAddress,
    required List<Map<String, dynamic>> products,
  }) async {
    final response = await ApiClient.post('/shipping/quote', {
      'pharmacyId': pharmacyId,
      'from': {'postal_code': fromCep},
      'to': {'postal_code': toCep},
      'destinationAddress': destinationAddress,
      'products': products,
    });

    final dynamic decodedBody = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (decodedBody is Map<String, dynamic>) {
        final details = decodedBody['details']?.toString();
        final error = decodedBody['error']?.toString();

        throw ShippingQuoteException(
          details?.isNotEmpty == true
              ? details!
              : error?.isNotEmpty == true
              ? error!
              : 'Nao foi possivel calcular o frete agora.',
        );
      }

      throw ShippingQuoteException('Nao foi possivel calcular o frete agora.');
    }

    if (decodedBody is! List) {
      throw ShippingQuoteException('Resposta invalida do servico de frete.');
    }

    return decodedBody
        .where((entry) => entry['price'] != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }
}
