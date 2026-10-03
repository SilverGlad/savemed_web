import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/api/api_response.dart';

void main() {
  group('ApiErrorMessage', () {
    test(
      'maps connection failures without exposing implementation details',
      () {
        const network = ApiConnectionException('Verifique sua internet.');
        const timeout = ApiConnectionException(
          'A conexao demorou demais.',
          kind: ApiConnectionFailure.timeout,
        );

        expect(
          ApiErrorMessage.forUser(network, fallback: 'Falha'),
          'Verifique sua internet.',
        );
        expect(timeout.kind, ApiConnectionFailure.timeout);
        expect(
          ApiErrorMessage.forUser(timeout, fallback: 'Falha'),
          timeout.message,
        );
      },
    );

    test('maps authorization and server status codes', () {
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException('detalhe', 401),
          fallback: 'Falha',
        ),
        'Sua sessão expirou. Entre novamente para continuar.',
      );
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException('detalhe', 403),
          fallback: 'Falha',
        ),
        'Você não tem permissão para realizar esta ação.',
      );
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException('SequelizeDatabaseError', 500),
          fallback: 'Falha',
        ),
        'Serviço temporariamente indisponível. Tente novamente em instantes.',
      );
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException(
            'Falha',
            500,
            requestId: '123e4567-e89b-12d3-a456-426614174000',
          ),
          fallback: 'Falha',
        ),
        'Serviço temporariamente indisponível. Tente novamente em instantes. '
        'Código de suporte: 123e4567-e89b-12d3-a456-426614174000.',
      );
    });

    test('keeps safe validation messages and hides technical ones', () {
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException('Email ja cadastrado', 409),
          fallback: 'Falha ao cadastrar',
        ),
        'Email ja cadastrado',
      );
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException(
            'Sequelize constraint PHARMACY_ID failed',
            400,
          ),
          fallback: 'Falha ao cadastrar',
        ),
        'Falha ao cadastrar',
      );
    });

    test('keeps safe catalog and transfer conflicts actionable for the admin', () {
      const conflicts = {
        'CATEGORY_HAS_PRODUCTS':
            'Reatribua ou remova os produtos vinculados antes de transferir a categoria.',
        'SUBCATEGORY_HAS_PRODUCTS':
            'Reatribua os produtos vinculados antes de mover a subcategoria.',
        'PRODUCT_HAS_INVENTORY':
            'Remova os itens de estoque vinculados antes de transferir o produto para outra farmácia.',
        'PRODUCT_HAS_SCOPED_INGREDIENTS':
            'Atualize os princípios ativos para os da nova farmácia antes de transferir o produto.',
      };

      for (final entry in conflicts.entries) {
        expect(
          ApiErrorMessage.forUser(
            ApiResponseException(
              entry.value,
              409,
              code: entry.key,
              field: 'PHARMACY_ID',
            ),
            fallback: 'Falha ao salvar',
          ),
          entry.value,
        );
      }
    });

    test('allows contextual status messages', () {
      expect(
        ApiErrorMessage.forUser(
          const ApiResponseException('Usuario nao encontrado', 404),
          fallback: 'Falha',
          statusMessages: const {404: 'Credenciais incorretas.'},
        ),
        'Credenciais incorretas.',
      );
    });
  });
}
