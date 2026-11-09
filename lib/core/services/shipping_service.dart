import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../utils/money_formatter.dart';

class ShippingQuoteException implements Exception {
  final String message;

  const ShippingQuoteException(this.message);

  @override
  String toString() => message;
}

class ShippingService {
  final Future<http.Response> Function(String path, Map body) _post;

  ShippingService({Future<http.Response> Function(String path, Map body)? post})
    : _post = post ?? ApiClient.post;

  Future<List<Map<String, dynamic>>> quote({
    required int pharmacyId,
    required String fromCep,
    required String toCep,
    required Map<String, dynamic> destinationAddress,
    required List<Map<String, dynamic>> products,
  }) async {
    final response = await _post('/shipping/quote', {
      'pharmacyId': pharmacyId,
      'from': {'postal_code': fromCep},
      'to': {'postal_code': toCep},
      'destinationAddress': destinationAddress,
      'products': products,
    });

    try {
      final data = ApiResponse.objects(
        response,
        expectedStatusCodes: {200},
        fallback: 'Não foi possível calcular o frete agora.',
      );
      final options = <Map<String, dynamic>>[];
      for (final option in data) {
        final rawPrice = option['price'];
        if (rawPrice == null) continue;

        if (parseNonNegativeFiniteAmount(rawPrice) == null) {
          throw const ShippingQuoteException(
            'Uma opção de frete retornou um preço inválido.',
          );
        }
        options.add(option);
      }
      return options;
    } on ApiResponseException catch (error) {
      throw ShippingQuoteException(error.message);
    }
  }
}
