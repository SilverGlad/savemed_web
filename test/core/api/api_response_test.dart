import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:savemed/core/api/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('decodes objects and lists', () {
      expect(
        ApiResponse.object(
          http.Response('{"ID":1}', 200),
          expectedStatusCodes: {200},
          fallback: 'Erro',
        )['ID'],
        1,
      );
      expect(
        ApiResponse.list(
          http.Response('[{"ID":1}]', 200),
          expectedStatusCodes: {200},
          fallback: 'Erro',
        ),
        hasLength(1),
      );
    });

    test('preserves a safe API error and status', () {
      expect(
        () => ApiResponse.object(
          http.Response('{"error":"Email ja cadastrado"}', 409),
          expectedStatusCodes: {201},
          fallback: 'Erro ao criar conta',
        ),
        throwsA(
          isA<ApiResponseException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having(
                (error) => error.message,
                'message',
                'Email ja cadastrado',
              ),
        ),
      );
    });

    test('handles non-JSON and unexpected response shapes', () {
      expect(
        () => ApiResponse.object(
          http.Response('<html>error</html>', 500),
          expectedStatusCodes: {200},
          fallback: 'Servidor indisponivel',
        ),
        throwsA(
          isA<ApiResponseException>().having(
            (error) => error.message,
            'message',
            'Servidor indisponivel',
          ),
        ),
      );
      expect(
        () => ApiResponse.object(
          http.Response('[]', 200),
          expectedStatusCodes: {200},
          fallback: 'Erro',
        ),
        throwsA(isA<ApiResponseException>()),
      );
    });
  });
}
