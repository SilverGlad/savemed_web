import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/utils/field_validators.dart';

void main() {
  group('field validators', () {
    test('normalizes digits', () {
      expect(digitsOnly('(11) 98765-4321'), '11987654321');
    });

    test('validates email format', () {
      expect(isValidEmail('usuario@savemed.com.br'), isTrue);
      expect(isValidEmail('usuario@'), isFalse);
      expect(isValidEmail(''), isFalse);
    });

    test('validates Brazilian phone lengths', () {
      expect(isValidPhone('(11) 98765-4321'), isTrue);
      expect(isValidPhone('(11) 3456-7890'), isTrue);
      expect(isValidPhone('1234'), isFalse);
    });

    test('validates password and confirmation', () {
      expect(validatePassword('1234567', '1234567'), isNotNull);
      expect(validatePassword('12345678', ''), 'Confirme sua senha.');
      expect(validatePassword('12345678', '87654321'), isNotNull);
      expect(validatePassword('12345678', '12345678'), isNull);
    });

    test('keeps password length and confirmation feedback independent', () {
      expect(validatePasswordLength('12345678'), isNull);
      expect(validatePasswordLength('1234567'), isNotNull);
      expect(
        validatePasswordConfirmation('12345678', ''),
        'Confirme sua senha.',
      );
      expect(validatePasswordConfirmation('12345678', '87654321'), isNotNull);
      expect(validatePasswordConfirmation('12345678', '12345678'), isNull);
      expect(validatePasswordConfirmation('1234567', ''), isNull);
    });
  });
}
