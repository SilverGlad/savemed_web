import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://api-savemed-146487220267.southamerica-east1.run.app/api';
  static const Duration requestTimeout = Duration(seconds: 20);
  static Future<void> Function()? _unauthorizedHandler;

  static void setUnauthorizedHandler(Future<void> Function() handler) {
    _unauthorizedHandler = handler;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔹 GET
  static Future<http.Response> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = await _headers();
    final response = await _withTimeout(http.get(uri, headers: headers));
    return _handleUnauthorized(response, headers);
  }

  // 🔹 POST
  static Future<http.Response> post(String path, Map body) async {
    final url = '$baseUrl$path';
    final headers = await _headers();
    final response = await _withTimeout(
      http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
    return _handleUnauthorized(response, headers);
  }

  // 🔹 PUT (já vamos precisar)
  static Future<http.Response> put(String path, Map body) async {
    final headers = await _headers();
    final response = await _withTimeout(
      http.put(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _handleUnauthorized(response, headers);
  }

  // 🔹 DELETE (opcional, mas bom ter)
  static Future<http.Response> delete(String path) async {
    final headers = await _headers();
    final response = await _withTimeout(
      http.delete(Uri.parse('$baseUrl$path'), headers: headers),
    );
    return _handleUnauthorized(response, headers);
  }

  static Future<http.Response> _handleUnauthorized(
    http.Response response,
    Map<String, String> headers,
  ) async {
    final authenticated = headers.containsKey('Authorization');
    if (authenticated && response.statusCode == 401) {
      await _unauthorizedHandler?.call();
    }
    return response;
  }

  static Future<http.Response> _withTimeout(
    Future<http.Response> request,
  ) async {
    try {
      return await request.timeout(requestTimeout);
    } on TimeoutException {
      throw const ApiConnectionException(
        'A conexao demorou demais. Verifique sua internet e tente novamente.',
      );
    } on http.ClientException {
      throw const ApiConnectionException(
        'Nao foi possivel conectar. Verifique sua internet e tente novamente.',
      );
    }
  }
}

class ApiConnectionException implements Exception {
  final String message;

  const ApiConnectionException(this.message);

  @override
  String toString() => message;
}
