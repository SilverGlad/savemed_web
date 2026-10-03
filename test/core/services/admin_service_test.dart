import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_token_vault.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
  });

  tearDown(() {
    ApiClient.setClientForTesting(null);
    TokenStorage.resetForTesting();
  });

  test('active ingredient list requests a pharmacy-scoped catalog', () async {
    http.Request? captured;
    ApiClient.setClientForTesting(
      MockClient((request) async {
        captured = request;
        return http.Response(
          '[{"ID":4,"NAME":"Vitamina C","PHARMACY_ID":12}]',
          200,
        );
      }),
    );

    final ingredients = await const AdminService().listActiveIngredients(
      pharmacyId: 12,
    );

    expect(captured?.url.path, '/api/active-ingredients');
    expect(captured?.url.queryParameters, {'pharmacyId': '12'});
    expect(ingredients.single.pharmacyId, 12);
  });

  test('pharmacy image upload uses the scoped multipart route', () async {
    http.Request? captured;
    ApiClient.setClientForTesting(
      MockClient((request) async {
        captured = request;
        return http.Response('{"message":"ok"}', 200);
      }),
    );

    await const AdminService().uploadPharmacyImage(
      12,
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'farmacia.png',
    );

    expect(captured?.url.path, '/api/pharmacies/12/upload');
    expect(
      captured?.headers['content-type'],
      startsWith('multipart/form-data;'),
    );
    expect(captured?.body, contains('name="image"'));
    expect(captured?.body, contains('filename="farmacia.png"'));
  });

  test('new pharmacy and subcategory saves retain API identifiers', () async {
    final requests = <http.Request>[];
    ApiClient.setClientForTesting(
      MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            'ID': request.url.path.endsWith('/pharmacies') ? 12 : 40,
          }),
          201,
        );
      }),
    );

    final service = const AdminService();
    final pharmacyId = await service.savePharmacy({'NAME': 'Farmácia Teste'});
    final subcategoryId = await service.saveSubcategory({
      'CATEGORY_ID': 8,
      'NAME': 'Dermocosméticos',
    });

    expect(pharmacyId, 12);
    expect(subcategoryId, 40);
    expect(jsonDecode(requests.first.body), {'NAME': 'Farmácia Teste'});
    expect(jsonDecode(requests.last.body), {
      'CATEGORY_ID': 8,
      'NAME': 'Dermocosméticos',
    });
  });
}
