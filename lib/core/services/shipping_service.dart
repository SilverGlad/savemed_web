import '../api/api_client.dart';
import '../api/api_response.dart';

class ShippingQuoteException implements Exception {
  final String message;

  const ShippingQuoteException(this.message);

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

    try {
      final data = ApiResponse.list(
        response,
        expectedStatusCodes: {200},
        fallback: 'Nao foi possivel calcular o frete agora.',
      );
      return data
          .whereType<Map<String, dynamic>>()
          .where((entry) => entry['price'] != null)
          .toList();
    } on ApiResponseException catch (error) {
      throw ShippingQuoteException(error.message);
    }
  }
}
