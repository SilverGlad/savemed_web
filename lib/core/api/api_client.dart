import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://api-savemed-146487220267.southamerica-east1.run.app/api';
  static const Duration requestTimeout = Duration(seconds: 20);
  static const String appVersion = '1.1.0+7';
  static Future<void> Function()? _unauthorizedHandler;
  static http.Client? _clientOverride;

  @visibleForTesting
  static void setClientForTesting(http.Client? client) {
    _clientOverride = client;
  }

  static void setUnauthorizedHandler(Future<void> Function()? handler) {
    _unauthorizedHandler = handler;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'X-App-Version': appVersion,
      'X-App-Platform': _platform,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String get _platform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  // 🔹 GET
  static Future<http.Response> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = await _headers();
    final response = await _withTimeout(
      _clientOverride?.get(uri, headers: headers) ??
          http.get(uri, headers: headers),
    );
    return _handleUnauthorized(response, headers);
  }

  // 🔹 POST
  static Future<http.Response> post(String path, Map body) async {
    final url = '$baseUrl$path';
    final headers = await _headers();
    final response = await _withTimeout(
      _clientOverride?.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          ) ??
          http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
    return _handleUnauthorized(response, headers);
  }

  // 🔹 PUT (já vamos precisar)
  static Future<http.Response> put(String path, Map body) async {
    final headers = await _headers();
    final response = await _withTimeout(
      _clientOverride?.put(
            Uri.parse('$baseUrl$path'),
            headers: headers,
            body: jsonEncode(body),
          ) ??
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
      _clientOverride?.delete(Uri.parse('$baseUrl$path'), headers: headers) ??
          http.delete(Uri.parse('$baseUrl$path'), headers: headers),
    );
    return _handleUnauthorized(response, headers);
  }

  static Future<http.Response> multipartPost(
    String path, {
    required String fieldName,
    required Uint8List bytes,
    required String filename,
  }) async {
    final headers = await _headers()
      ..remove('Content-Type');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'))
      ..headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, bytes, filename: filename),
    );
    final stream = _clientOverride?.send(request) ?? request.send();
    final response = await _withTimeout(stream.then(http.Response.fromStream));
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
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
        kind: ApiConnectionFailure.timeout,
      );
    } on http.ClientException {
      throw const ApiConnectionException(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
        kind: ApiConnectionFailure.network,
      );
    }
  }
}

enum ApiConnectionFailure { network, timeout }

class ApiConnectionException implements Exception {
  final String message;
  final ApiConnectionFailure kind;

  const ApiConnectionException(
    this.message, {
    this.kind = ApiConnectionFailure.network,
  });

  @override
  String toString() => message;
}
