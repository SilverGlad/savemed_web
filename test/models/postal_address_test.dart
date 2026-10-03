import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/postal_address.dart';

void main() {
  test('parses saved-address fields and normalizes a string id', () {
    final address = PostalAddress.fromJson({
      'id': '17',
      'cep': '01001000',
      'street': 'Rua A',
      'number': '20',
      'city': 'Sao Paulo',
      'state': 'SP',
      'isDefault': true,
    });

    expect(address.id, 17);
    expect(address.cep, '01001000');
    expect(address.street, 'Rua A');
    expect(address.number, '20');
    expect(address.isDefault, isTrue);
    expect(address.toShippingJson(), {
      'id': '17',
      'cep': '01001000',
      'street': 'Rua A',
      'number': '20',
      'city': 'Sao Paulo',
      'state': 'SP',
      'isDefault': true,
    });
  });

  test('keeps the quote representation and legacy create payload distinct', () {
    final address = PostalAddress.fromJson({
      'ID': 17,
      'CEP': '01001000',
      'STREET': 'Rua A',
      'NUMBER': '20',
      'COMPLEMENT': null,
      'NEIGHBORHOOD': 'Centro',
      'CITY': 'Sao Paulo',
      'STATE': 'SP',
      'IS_DEFAULT': true,
      'USER_ID': 4,
    });

    expect(address.toJson()['USER_ID'], 4);
    expect(address.toJson()['ID'], 17);
    expect(address.toShippingJson(), {
      'ID': 17,
      'CEP': '01001000',
      'STREET': 'Rua A',
      'NUMBER': '20',
      'COMPLEMENT': null,
      'NEIGHBORHOOD': 'Centro',
      'CITY': 'Sao Paulo',
      'STATE': 'SP',
      'IS_DEFAULT': true,
      'USER_ID': 4,
    });
    expect(address.toRequestJson(), {
      'CEP': '01001000',
      'STREET': 'Rua A',
      'NUMBER': '20',
      'COMPLEMENT': null,
      'NEIGHBORHOOD': 'Centro',
      'CITY': 'Sao Paulo',
      'STATE': 'SP',
      'IS_DEFAULT': true,
    });
  });
}
