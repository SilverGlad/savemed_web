import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../utils/field_validators.dart';
import '../../models/cep_address.dart';

abstract final class CepLookupService {
  static const _timeout = Duration(seconds: 10);
  static http.Client? _clientOverride;

  @visibleForTesting
  static void setClientForTesting(http.Client? client) {
    _clientOverride = client;
  }

  static Future<CepAddress?> lookup(
    String zipcode, {
    http.Client? client,
  }) async {
    final normalizedZipcode = digitsOnly(zipcode);
    if (normalizedZipcode.length != 8) return null;

    final activeClient = client ?? _clientOverride ?? http.Client();
    final ownsClient = client == null && _clientOverride == null;
    try {
      final response = await activeClient
          .get(Uri.parse('https://viacep.com.br/ws/$normalizedZipcode/json/'))
          .timeout(_timeout);
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw ApiResponseException(
          'Não foi possível consultar o CEP.',
          response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['erro'] == true) {
        return null;
      }
      final city = (decoded['localidade'] ?? '').toString().trim();
      final state = (decoded['uf'] ?? '').toString().trim().toUpperCase();
      if (city.isEmpty || state.length != 2) return null;

      return CepAddress(
        zipcode: normalizedZipcode,
        city: city,
        state: state,
        street: (decoded['logradouro'] ?? '').toString().trim(),
        neighborhood: (decoded['bairro'] ?? '').toString().trim(),
      );
    } on TimeoutException {
      throw const ApiConnectionException(
        'A consulta do CEP demorou demais. Preencha o endereço manualmente.',
        kind: ApiConnectionFailure.timeout,
      );
    } on http.ClientException {
      throw const ApiConnectionException(
        'Não foi possível consultar o CEP. Preencha o endereço manualmente.',
      );
    } finally {
      if (ownsClient) activeClient.close();
    }
  }
}
