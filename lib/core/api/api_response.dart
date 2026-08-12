import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiResponseException implements Exception {
  final String message;
  final int statusCode;

  const ApiResponseException(this.message, this.statusCode);

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

abstract final class ApiResponse {
  static Map<String, dynamic> object(
    http.Response response, {
    required Set<int> expectedStatusCodes,
    required String fallback,
  }) {
    final decoded = _decode(response, expectedStatusCodes, fallback);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiResponseException(
      'Resposta invalida do servidor.',
      response.statusCode,
    );
  }

  static List<dynamic> list(
    http.Response response, {
    required Set<int> expectedStatusCodes,
    required String fallback,
  }) {
    final decoded = _decode(response, expectedStatusCodes, fallback);
    if (decoded is List<dynamic>) return decoded;
    throw ApiResponseException(
      'Resposta invalida do servidor.',
      response.statusCode,
    );
  }

  static void success(
    http.Response response, {
    required Set<int> expectedStatusCodes,
    required String fallback,
  }) {
    if (expectedStatusCodes.contains(response.statusCode)) return;
    throw _error(response, fallback);
  }

  static dynamic _decode(
    http.Response response,
    Set<int> expectedStatusCodes,
    String fallback,
  ) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      if (!expectedStatusCodes.contains(response.statusCode)) {
        throw _error(response, fallback);
      }
      throw ApiResponseException(
        'Resposta invalida do servidor.',
        response.statusCode,
      );
    }
    if (!expectedStatusCodes.contains(response.statusCode)) {
      throw _error(response, fallback, decoded: decoded);
    }
    return decoded;
  }

  static ApiResponseException _error(
    http.Response response,
    String fallback, {
    dynamic decoded,
  }) {
    dynamic data = decoded;
    if (data == null) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {}
    }
    final message = data is Map<String, dynamic>
        ? data['details']?.toString() ?? data['error']?.toString() ?? fallback
        : fallback;
    return ApiResponseException(message, response.statusCode);
  }
}
