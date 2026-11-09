import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/address_service.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/models/postal_address.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_token_vault.dart';

void main() {
  late http.Client client;

  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    ApiClient.setClientForTesting(null);
    client.close();
    TokenStorage.resetForTesting();
  });

  test('decodes address objects into a typed list', () async {
    http.Request? request;
    client = MockClient((incoming) async {
      request = incoming;
      return http.Response(
        jsonEncode([
          {'ID': 17, 'CEP': '01001000'},
        ]),
        200,
      );
    });
    ApiClient.setClientForTesting(client);

    final addresses = await AddressService().getUserAddresses(9);

    expect(request?.url.path, '/api/addresses/user/9');
    expect(addresses, hasLength(1));
    expect(addresses.single.id, 17);
    expect(addresses.single.cep, '01001000');
  });

  test('rejects malformed rows instead of hiding saved addresses', () async {
    client = MockClient(
      (_) async => http.Response(
        jsonEncode([
          {'ID': 17, 'CEP': '01001000'},
          'malformed entry',
        ]),
        200,
        headers: {'x-request-id': 'request-1234'},
      ),
    );
    ApiClient.setClientForTesting(client);

    await expectLater(
      AddressService().getUserAddresses(9),
      throwsA(
        isA<ApiResponseException>()
            .having((error) => error.statusCode, 'statusCode', 200)
            .having((error) => error.requestId, 'requestId', 'request-1234'),
      ),
    );
  });

  test(
    'serializes typed address writes with the legacy payload keys',
    () async {
      final requests = <http.Request>[];
      client = MockClient((incoming) async {
        requests.add(incoming);
        return http.Response('', incoming.method == 'POST' ? 201 : 200);
      });
      ApiClient.setClientForTesting(client);
      final address = PostalAddress(
        cep: '01001000',
        street: 'Rua A',
        number: '20',
        city: 'Sao Paulo',
        state: 'SP',
        isDefault: true,
      );

      await AddressService().createAddress(address);
      await AddressService().updateAddress(17, address);

      expect(requests.map((request) => request.method), ['POST', 'PUT']);
      expect(requests.map((request) => request.url.path), [
        '/api/addresses',
        '/api/addresses/17',
      ]);
      for (final request in requests) {
        expect(jsonDecode(request.body), address.toRequestJson());
      }
    },
  );
}
