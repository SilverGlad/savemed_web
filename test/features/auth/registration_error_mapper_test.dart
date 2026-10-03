import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/features/auth/registration_error_mapper.dart';

void main() {
  group('RegistrationErrorMapper', () {
    test('maps stable duplicate codes to safe messages and fields', () {
      const cases = <(String, String, String, String)>[
        (
          'EMAIL_IN_USE',
          'administrator.EMAIL',
          'Este e-mail já está em uso.',
          'email',
        ),
        (
          'CNPJ_IN_USE',
          'pharmacy.CNPJ',
          'Este CNPJ já está cadastrado.',
          'cnpj',
        ),
      ];

      for (final (code, field, message, fieldKey) in cases) {
        final error = ApiResponseException(
          'Conflict',
          409,
          code: code,
          field: field,
        );
        expect(RegistrationErrorMapper.message(error), message);
        expect(RegistrationErrorMapper.fieldError(error), (fieldKey, message));
      }
    });

    test('supports legacy duplicate messages when the field is identified', () {
      const error = ApiResponseException(
        'Este email ja esta em uso.',
        409,
        field: 'administrator.EMAIL',
      );

      expect(
        RegistrationErrorMapper.message(error),
        'Este e-mail já está em uso.',
      );
      expect(RegistrationErrorMapper.fieldError(error), (
        'email',
        'Este e-mail já está em uso.',
      ));
    });

    test('does not treat field-only phone validation as a duplicate', () {
      const error = ApiResponseException(
        'Informe um telefone válido com DDD.',
        422,
        code: 'INVALID_PHONE',
        field: 'administrator.PHONE_NUMBER',
      );

      expect(RegistrationErrorMapper.fieldError(error), isNull);
      expect(
        RegistrationErrorMapper.message(error),
        'Informe um telefone válido com DDD.',
      );
    });

    test('does not impose phone uniqueness from legacy conflict responses', () {
      const codedConflict = ApiResponseException(
        'Conflict',
        409,
        code: 'PHONE_IN_USE',
        field: 'administrator.PHONE_NUMBER',
      );
      const legacyConflict = ApiResponseException(
        'Este telefone já está cadastrado.',
        409,
        field: 'administrator.PHONE_NUMBER',
      );
      const supportMessage =
          'Não foi possível concluir o cadastro. Entre em contato com o suporte da SaveMed.';

      for (final error in [codedConflict, legacyConflict]) {
        expect(RegistrationErrorMapper.message(error), supportMessage);
        expect(RegistrationErrorMapper.fieldError(error), isNull);
      }
    });

    test('keeps uncertain registration outcomes safe to retry', () {
      const network = ApiConnectionException('Sem conexão.');
      const server = ApiResponseException('Falha interna', 500);

      for (final error in [network, server]) {
        expect(RegistrationErrorMapper.hasUncertainOutcome(error), isTrue);
        expect(
          RegistrationErrorMapper.message(error),
          'Não foi possível confirmar se a conta foi criada. Tente entrar '
          'com este e-mail antes de enviar novamente.',
        );
      }
    });

    test('does not mark validation errors as uncertain outcomes', () {
      const error = ApiResponseException('Conflict', 409);

      expect(RegistrationErrorMapper.hasUncertainOutcome(error), isFalse);
    });
  });
}
