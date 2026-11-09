import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/pharmacy_registration_request.dart';

void main() {
  const request = PharmacyRegistrationRequest(
    administratorName: ' Responsavel ',
    email: ' ADMIN@EXAMPLE.COM ',
    password: 'senha123',
    cnpj: '04.252.011/0001-10',
    phone: '(11) 99999-9999',
    pharmacyName: ' Farmacia Teste ',
    city: ' Sao Paulo ',
    state: 'sp',
    zipcode: '01001-000',
  );

  test('normalizes the transactional pharmacy registration payload', () {
    expect(request.toJson(), {
      'pharmacy': {
        'NAME': 'Farmacia Teste',
        'CNPJ': '04252011000110',
        'PHONE': '11999999999',
        'CITY': 'Sao Paulo',
        'STATE': 'SP',
        'ZIPCODE': '01001000',
      },
      'administrator': {
        'NAME': 'Responsavel',
        'EMAIL': 'admin@example.com',
        'PASSWORD': 'senha123',
        'PHONE_NUMBER': '11999999999',
      },
    });
  });
}
