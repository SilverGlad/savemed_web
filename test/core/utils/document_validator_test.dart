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
    });
  });
}
