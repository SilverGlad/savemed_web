import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:savemed/core/api/api_response.dart';

void main() {
  group('ApiResponse request correlation', () {
    test('captures a valid request id from response headers', () {
      final response = http.Response(
        '{"error":"Falha"}',
        500,
        headers: {'x-request-id': '123e4567-e89b-12d3-a456-426614174000'},
      );

      expect(
        () => ApiResponse.object(
          response,
          expectedStatusCodes: const {200},
          fallback: 'Falha',
        ),
        throwsA(
          isA<ApiResponseException>().having(
            (error) => error.requestId,
            'requestId',
            '123e4567-e89b-12d3-a456-426614174000',
          ),
        ),
      );
    });

    test('rejects malformed request ids', () {
      final response = http.Response(
        '{"error":"Falha","requestId":"<script>"}',
        500,
      );

      expect(
        () => ApiResponse.object(
          response,
          expectedStatusCodes: const {200},
          fallback: 'Falha',
        ),
        throwsA(
          isA<ApiResponseException>().having(
            (error) => error.requestId,
            'requestId',
            isNull,
          ),
        ),
      );
    });

    test('captures only stable API error codes', () {
      final response = http.Response(
        '{"error":"Falha","code":"PASSWORD_SETUP_REQUIRED"}',
        403,
      );

      expect(
        () => ApiResponse.object(
          response,
          expectedStatusCodes: const {200},
          fallback: 'Falha',
        ),
        throwsA(
          isA<ApiResponseException>().having(
            (error) => error.code,
            'code',
            'PASSWORD_SETUP_REQUIRED',
          ),
        ),
      );
    });

    test('captures a safe API field for inline validation', () {
      final response = http.Response(
        '{"error":"Conflict","code":"CNPJ_IN_USE","field":"pharmacy.CNPJ"}',
        409,
      );

      expect(
        () => ApiResponse.object(
          response,
          expectedStatusCodes: const {200},
          fallback: 'Falha',
        ),
        throwsA(
          isA<ApiResponseException>().having(
            (error) => error.field,
            'field',
            'pharmacy.CNPJ',
          ),
        ),
      );
    });

    test('ignores malformed API field names', () {
      final response = http.Response(
        '{"error":"Falha","field":"<script>alert(1)</script>"}',
        409,
      );

      expect(
        () => ApiResponse.object(
          response,
          expectedStatusCodes: const {200},
          fallback: 'Falha',
        ),
        throwsA(
          isA<ApiResponseException>().having(
            (error) => error.field,
            'field',
            isNull,
          ),
        ),
      );
    });
  });
}
