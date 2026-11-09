import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_token_vault.dart';

void main() {
  late http.Client client;

  void replaceClient(http.Client replacement) {
    client.close();
    client = replacement;
    ApiClient.setClientForTesting(client);
  }

  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
    ApiClient.setUnauthorizedHandler(null);
    client = MockClient((_) async => http.Response('', 200));
    ApiClient.setClientForTesting(client);
  });

  tearDown(() {
    ApiClient.setClientForTesting(null);
    ApiClient.setUnauthorizedHandler(null);
    client.close();
    TokenStorage.resetForTesting();
  });

  test(
    'adds client metadata without sending an absent session token',
    () async {
      http.Request? captured;
      replaceClient(
        MockClient((request) async {
          captured = request;
          return http.Response('', 200);
        }),
      );

      await ApiClient.get('/inventory/highlights', query: {'limit': '10'});

      expect(captured?.url.path, '/api/inventory/highlights');
      expect(captured?.url.queryParameters, {'limit': '10'});
      expect(captured?.headers['x-app-version'], ApiClient.appVersion);
      expect(
        captured?.headers['x-app-platform'],
        isIn({'web', 'android', 'ios', 'macos', 'windows', 'linux', 'fuchsia'}),
      );
      expect(captured?.headers.containsKey('authorization'), isFalse);
    },
  );

  test('preserves write methods, routes, and JSON request bodies', () async {
    final requests = <http.Request>[];
    replaceClient(
      MockClient((request) async {
        requests.add(request);
        return http.Response('', 200);
      }),
    );

    await ApiClient.post('/users/login', {'EMAIL': 'client@example.com'});
    await ApiClient.put('/users/me', {'NAME': 'Cliente SaveMed'});
    await ApiClient.delete('/addresses/42');

    expect(requests.map((request) => request.method), [
      'POST',
      'PUT',
      'DELETE',
    ]);
    expect(requests.map((request) => request.url.path), [
      '/api/users/login',
      '/api/users/me',
      '/api/addresses/42',
    ]);
    expect(jsonDecode(requests[0].body), {'EMAIL': 'client@example.com'});
    expect(jsonDecode(requests[1].body), {'NAME': 'Cliente SaveMed'});
    expect(requests[2].body, isEmpty);
    for (final request in requests) {
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['x-app-version'], ApiClient.appVersion);
    }
  });

  test(
    'invokes session handling on 401 only for authenticated requests',
    () async {
      var handled = 0;
      replaceClient(MockClient((_) async => http.Response('', 401)));
      ApiClient.setUnauthorizedHandler(() async => handled++);

      await ApiClient.get('/private');
      expect(handled, 0);

      await TokenStorage.saveToken('session-token');
      await ApiClient.get('/private');

      expect(handled, 1);
    },
  );

  test(
    'multipart uploads preserve auth and let the client set the boundary',
    () async {
      await TokenStorage.saveToken('session-token');
      http.Request? captured;
      replaceClient(
        MockClient((request) async {
          captured = request;
          return http.Response('', 201);
        }),
      );

      final response = await ApiClient.multipartPost(
        '/admin/categories/12/image',
        fieldName: 'image',
        bytes: Uint8List.fromList([0, 1, 2, 255]),
        filename: 'category.png',
      );

      expect(response.statusCode, 201);
      expect(captured?.method, 'POST');
      expect(captured?.url.path, '/api/admin/categories/12/image');
      expect(captured?.headers['authorization'], 'Bearer session-token');
      expect(
        captured?.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(captured?.headers['content-type'], isNot('application/json'));
      final body = latin1.decode(captured!.bodyBytes);
      expect(body, contains('name="image"; filename="category.png"'));
      expect(body, contains(String.fromCharCode(255)));
    },
  );

  test('maps transport errors to a safe connection error', () async {
    replaceClient(
      MockClient((_) async {
        throw http.ClientException('internal socket detail');
      }),
    );

    await expectLater(
      ApiClient.get('/inventory/highlights'),
      throwsA(
        isA<ApiConnectionException>()
            .having((error) => error.kind, 'kind', ApiConnectionFailure.network)
            .having(
              (error) => error.message,
              'safe message',
              isNot(contains('internal socket detail')),
            ),
      ),
    );
  });
}
