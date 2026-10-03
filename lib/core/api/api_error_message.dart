import 'api_client.dart';
import 'api_response.dart';

abstract final class ApiErrorMessage {
  static String forUser(
    Object error, {
    required String fallback,
    Map<int, String> statusMessages = const {},
    bool allowValidationMessage = true,
  }) {
    if (error is ApiConnectionException) return error.message;

    if (error is ApiResponseException) {
      final statusMessage = statusMessages[error.statusCode];
      if (statusMessage != null) {
        return _withSupportCode(statusMessage, error);
      }

      if (error.isUnauthorized) {
        return 'Sua sessão expirou. Entre novamente para continuar.';
      }
      if (error.isForbidden) {
        return 'Você não tem permissão para realizar esta ação.';
      }
      if (error.isServerError) {
        return _withSupportCode(
          'Serviço temporariamente indisponível. Tente novamente em instantes.',
          error,
        );
      }
      if (allowValidationMessage && error.isValidation) {
        return _safeApiMessage(error.message) ?? fallback;
      }
    }

    return fallback;
  }

  static String? _safeApiMessage(String message) {
    final value = message.trim().replaceFirst('Exception: ', '');
    final technicalPattern = RegExp(
      r'(sequelize|postgres|sql|stack|trace|jwt|secret|token|_id|constraint|syntax|database)',
      caseSensitive: false,
    );

    if (value.isEmpty ||
        value.length > 180 ||
        technicalPattern.hasMatch(value)) {
      return null;
    }
    return value;
  }

  static String _withSupportCode(String message, ApiResponseException error) {
    if (!error.isServerError || error.requestId == null) return message;
    return '$message Código de suporte: ${error.requestId}.';
  }
}
