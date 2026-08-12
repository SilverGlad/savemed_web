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

String? validatePassword(String password, String confirmation) {
  if (password.length < 8) {
    return 'A senha deve ter pelo menos 8 caracteres.';
  }
  if (password != confirmation) {
    return 'A confirmacao da senha nao confere.';
  }
  return null;
}
