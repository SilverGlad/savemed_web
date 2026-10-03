import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/storage/token_storage.dart';

import '../../support/in_memory_token_vault.dart';

void main() {
  test(
    'password recovery requests the current API route and email field',
    () async {
      late http.Request sentRequest;
      final client = MockClient((request) async {
        sentRequest = request;
        return http.Response(jsonEncode({'message': 'Código enviado'}), 200);
      });
      TokenStorage.resetForTesting();
      TokenStorage.setVaultForTesting(InMemoryTokenVault());
      SharedPreferences.setMockInitialValues({});
      ApiClient.setClientForTesting(client);
      addTearDown(() {
        ApiClient.setClientForTesting(null);
        client.close();
        TokenStorage.resetForTesting();
      });

      final result = await const AuthService().forgotPassword(
        email: 'qa@example.com',
      );

      expect(result, 'Código enviado');
      expect(sentRequest.url.path, '/api/users/forgot-password');
      expect(jsonDecode(sentRequest.body), {'EMAIL': 'qa@example.com'});
    },
  );

  test('password reset sends email, one-time code and new password', () async {
    late http.Request sentRequest;
    final client = MockClient((request) async {
      sentRequest = request;
      return http.Response(jsonEncode({'message': 'Senha redefinida'}), 200);
    });
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
    ApiClient.setClientForTesting(client);
    addTearDown(() {
      ApiClient.setClientForTesting(null);
      client.close();
      TokenStorage.resetForTesting();
    });

    final result = await const AuthService().resetPassword(
      email: 'qa@example.com',
      code: '123456',
      password: 'senha-de-teste',
    );

    expect(result, 'Senha redefinida');
    expect(sentRequest.url.path, '/api/users/reset-password');
    expect(jsonDecode(sentRequest.body), {
      'EMAIL': 'qa@example.com',
      'CODE': '123456',
      'PASSWORD': 'senha-de-teste',
    });
  });

  for (final unavailableStatus in [404, 405]) {
    test(
      'pharmacy registration does not issue legacy writes after HTTP $unavailableStatus',
      () async {
        final requests = <http.Request>[];
        final client = MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({'error': 'route unavailable'}),
            unavailableStatus,
          );
        });
        TokenStorage.resetForTesting();
        TokenStorage.setVaultForTesting(InMemoryTokenVault());
        SharedPreferences.setMockInitialValues({});
        ApiClient.setClientForTesting(client);
        addTearDown(() {
          ApiClient.setClientForTesting(null);
          client.close();
          TokenStorage.resetForTesting();
        });

        await expectLater(
          const AuthService().registerSeller(
            name: 'Farmacêutico Teste',
            email: 'farmacia@example.com',
            password: 'senha-segura',
            cnpj: '04.252.011/0001-10',
            phone: '(11) 99999-9999',
            pharmacyName: 'Farmácia Teste',
            city: 'São Paulo',
            state: 'SP',
            zipcode: '01001-000',
          ),
          throwsA(
            isA<ApiResponseException>().having(
              (error) => error.statusCode,
              'status code',
              unavailableStatus,
            ),
          ),
        );

        expect(requests, hasLength(1));
        expect(requests.single.url.path, '/api/pharmacies/register');
      },
    );
  }
}
