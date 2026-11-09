import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_error_message.dart';
import 'package:savemed/core/api/api_response.dart';

abstract final class RegistrationErrorMapper {
  static const _phoneConflictMessage =
      'Não foi possível concluir o cadastro. Entre em contato com o suporte da SaveMed.';

  static bool hasUncertainOutcome(Object error) =>
      error is ApiConnectionException ||
      error is ApiResponseException && error.isServerError;

  static String message(Object error) {
    if (hasUncertainOutcome(error)) {
      return 'Não foi possível confirmar se a conta foi criada. Tente entrar '
          'com este e-mail antes de enviar novamente.';
    }

    if (error is ApiResponseException) {
      switch (error.code) {
        case 'EMAIL_IN_USE':
          return 'Este e-mail já está em uso.';
        case 'CNPJ_IN_USE':
          return 'Este CNPJ já está cadastrado.';
        case 'PHONE_IN_USE':
          return _phoneConflictMessage;
      }
    }

    final normalized = error is ApiResponseException
        ? error.message.toLowerCase()
        : '';
    final duplicateConflict =
        normalized.contains('cadastr') || normalized.contains('uso');

    if (normalized.contains('email') && duplicateConflict) {
      return 'Este e-mail já está em uso.';
    }
    if (normalized.contains('cnpj') && duplicateConflict) {
      return 'Este CNPJ já está cadastrado.';
    }
    if ((normalized.contains('telefone') || normalized.contains('phone')) &&
        duplicateConflict) {
      return _phoneConflictMessage;
    }

    return ApiErrorMessage.forUser(
      error,
      fallback: 'Não foi possível criar a conta. Tente novamente em instantes.',
    );
  }

  static (String, String)? fieldError(Object error) {
    if (error is! ApiResponseException) return null;
    final field = error.field?.toLowerCase() ?? '';
    final normalized = error.message.toLowerCase();
    final isDuplicateMessage =
        normalized.contains('cadastr') || normalized.contains('em uso');

    if (error.code == 'EMAIL_IN_USE' ||
        isDuplicateMessage && field.endsWith('.email')) {
      return ('email', 'Este e-mail já está em uso.');
    }
    if (error.code == 'CNPJ_IN_USE' ||
        isDuplicateMessage && field.endsWith('.cnpj')) {
      return ('cnpj', 'Este CNPJ já está cadastrado.');
    }
    return null;
  }
}
