import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://api-savemed-production.up.railway.app/api';

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

    debugPrint('➡️ GET $uri');
    debugPrint('Headers: $headers');

    final res = await http.get(uri, headers: headers);

    debugPrint('⬅️ RESPONSE ${res.statusCode} ($path)');
    debugPrint(res.body);

    return res;
  }

  // 🔹 POST
  static Future<http.Response> post(String path, Map body) async {
    final url = '$baseUrl$path';
    final headers = await _headers();
    final encodedBody = jsonEncode(body);

    debugPrint('➡️ POST $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $encodedBody');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: encodedBody,
    );

    debugPrint('⬅️ Response ${response.statusCode}');
    debugPrint(response.body);

    return response;
  }

  // 🔹 PUT (já vamos precisar)
  static Future<http.Response> put(String path, Map body) async {
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  // 🔹 DELETE (opcional, mas bom ter)
  static Future<http.Response> delete(String path) async {
    return http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
  }
}
