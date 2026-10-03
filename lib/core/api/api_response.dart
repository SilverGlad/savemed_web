import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiResponseException implements Exception {
  final String message;
  final int statusCode;
  final String? requestId;
  final String? code;
  final String? field;

  const ApiResponseException(
    this.message,
    this.statusCode, {
    this.requestId,
    this.code,
    this.field,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation =>
      statusCode == 400 || statusCode == 409 || statusCode == 422;
  bool get isServerError => statusCode >= 500;

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
      'Resposta inválida do servidor.',
      response.statusCode,
      requestId: _requestId(response),
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
      'Resposta inválida do servidor.',
      response.statusCode,
      requestId: _requestId(response),
    );
  }

  static List<Map<String, dynamic>> objects(
    http.Response response, {
    required Set<int> expectedStatusCodes,
    required String fallback,
  }) {
    final decoded = list(
      response,
      expectedStatusCodes: expectedStatusCodes,
      fallback: fallback,
    );
    if (decoded.any((item) => item is! Map<String, dynamic>)) {
      throw ApiResponseException(
        'Resposta inválida do servidor.',
        response.statusCode,
        requestId: _requestId(response),
      );
    }
    return decoded.cast<Map<String, dynamic>>();
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
        'Resposta inválida do servidor.',
        response.statusCode,
        requestId: _requestId(response),
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
    return ApiResponseException(
      message,
      response.statusCode,
      requestId: _requestId(response, data: data),
      code: _errorCode(data),
      field: _errorField(data),
    );
  }

  static String? _requestId(http.Response response, {dynamic data}) {
    final rawHeader = response.headers['x-request-id'];
    final rawBody = data is Map<String, dynamic> ? data['requestId'] : null;
    final value = (rawHeader ?? rawBody?.toString())?.trim();
    if (value == null || !RegExp(r'^[A-Za-z0-9-]{8,64}$').hasMatch(value)) {
      return null;
    }
    return value;
  }

  static String? _errorCode(dynamic data) {
    final value = data is Map<String, dynamic>
        ? data['code']?.toString().trim()
        : null;
    if (value == null || !RegExp(r'^[A-Z][A-Z0-9_]{2,63}$').hasMatch(value)) {
      return null;
    }
    return value;
  }

  static String? _errorField(dynamic data) {
    final value = data is Map<String, dynamic>
        ? data['field']?.toString().trim()
        : null;
    if (value == null ||
        value.isEmpty ||
        value.length > 80 ||
        !RegExp(r'^[A-Za-z][A-Za-z0-9_.]*$').hasMatch(value)) {
      return null;
    }
    return value;
  }
}
