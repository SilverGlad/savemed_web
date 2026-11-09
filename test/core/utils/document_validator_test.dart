import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/utils/document_validator.dart';

void main() {
  group('document validators', () {
    test('accepts formatted valid CPF and rejects invalid values', () {
      expect(isValidCPF('529.982.247-25'), isTrue);
      expect(isValidCPF('111.111.111-11'), isFalse);
      expect(isValidCPF('123'), isFalse);
    });

    test('accepts formatted valid CNPJ and rejects invalid values', () {
      expect(isValidCNPJ('04.252.011/0001-10'), isTrue);
      expect(isValidCNPJ('11.111.111/1111-11'), isFalse);
      expect(isValidCNPJ('123'), isFalse);
      expect(isValidCNPJ('00.000.000/0000-00'), isFalse);
      expect(isValidCNPJ('04.252.011/0001-11'), isFalse);
      expect(isValidCNPJ('04252011000110'), isTrue);
    });

    test('rejects a CNPJ with incorrect check digits', () {
      expect(isValidCNPJ('12.345.678/0001-00'), isFalse);
    });
  });
}
