import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/services/cep_lookup_service.dart';

void main() {
  test('normalizes CEP and parses the address returned by ViaCEP', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/ws/01001000/json/');
      return http.Response(
        '{"cep":"01001-000","logradouro":"Praca da Se","bairro":"Se","localidade":"Sao Paulo","uf":"SP"}',
        200,
      );
    });

    final address = await CepLookupService.lookup('01001-000', client: client);

    expect(address?.zipcode, '01001000');
    expect(address?.city, 'Sao Paulo');
    expect(address?.state, 'SP');
    expect(address?.street, 'Praca da Se');
    expect(address?.neighborhood, 'Se');
  });

  test('returns null for an unknown or invalid CEP', () async {
    final client = MockClient((_) async => http.Response('{"erro":true}', 200));

    expect(await CepLookupService.lookup('123', client: client), isNull);
    expect(await CepLookupService.lookup('00000-000', client: client), isNull);
  });

  test('keeps non-success responses classified for the UI', () async {
    final client = MockClient((_) async => http.Response('indisponivel', 503));

    await expectLater(
      CepLookupService.lookup('01001000', client: client),
      throwsA(
        isA<ApiResponseException>().having(
          (error) => error.statusCode,
          'statusCode',
          503,
        ),
      ),
    );
  });
}
