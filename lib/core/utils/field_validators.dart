String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

bool isValidRequiredText(String value, {int minLength = 2}) {
  return value.trim().length >= minLength;
}

bool isValidEmail(String value) {
  final email = value.trim();
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
}

bool isValidPhone(String value) {
  final digits = digitsOnly(value);
  return digits.length == 10 || digits.length == 11;
}

String? validatePasswordLength(String password) {
  if (password.length < 8) {
    return 'A senha deve ter pelo menos 8 caracteres.';
  }

  return null;
}

String? validatePasswordConfirmation(String password, String confirmation) {
  if (password.length < 8) return null;
  if (confirmation.isEmpty) return 'Confirme sua senha.';
  if (password != confirmation) {
    return 'A confirmação da senha não confere.';
  }

  return null;
}

String? validatePassword(String password, String confirmation) {
  final lengthError = validatePasswordLength(password);
  if (lengthError != null) return lengthError;

  return validatePasswordConfirmation(password, confirmation);
}
