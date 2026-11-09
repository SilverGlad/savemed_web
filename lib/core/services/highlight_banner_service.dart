import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';

class HighlightBannerService {
  String get _baseUrl {
    if (kIsWeb &&
        (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1')) {
      return 'http://localhost:3000/api';
    }

    return ApiClient.baseUrl;
  }

  Future<List<String>> getBannerImages() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/highlights'))
        .timeout(ApiClient.requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar banners');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => item as Map<String, dynamic>)
        .map((item) => item['HIGHLIGHT_IMAGE']?.toString() ?? '')
        .where((image) => image.isNotEmpty)
        .toList();
  }
}
