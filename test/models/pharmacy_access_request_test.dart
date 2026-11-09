import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/pharmacy_access_request.dart';
import 'package:savemed/models/pharmacy_access_request_summary.dart';
import 'package:savemed/models/pharmacy_search_result.dart';

void main() {
  test('normalizes the public access request payload without a password', () {
    const request = PharmacyAccessRequest(
      pharmacyId: 9,
      responsibleName: ' Maria Silva ',
      responsibleDocument: '529.982.247-25',
      email: ' MARIA@EXAMPLE.COM ',
      phone: '(11) 99999-9999',
    );

    expect(request.toJson(), {
      'PHARMACY_ID': 9,
      'NAME': 'Maria Silva',
      'RESPONSIBLE_DOCUMENT': '52998224725',
      'EMAIL': 'maria@example.com',
      'PHONE_NUMBER': '11999999999',
    });
    expect(request.toJson().containsKey('PASSWORD'), isFalse);
  });

  test('parses safe pharmacy search and administrative request contracts', () {
    final pharmacy = PharmacySearchResult.fromJson({
      'ID': '9',
      'NAME': 'Farmacia Central',
      'CNPJ_MASKED': '**.***.***/****-1234',
      'CITY': 'Sao Paulo',
      'STATE': 'SP',
    });
    expect(pharmacy.location, 'Sao Paulo - SP');

    final request = PharmacyAccessRequestSummary.fromJson({
      'ID': 21,
      'PHARMACY_ID': 9,
      'PHARMACY': {'NAME': 'Farmacia Central'},
      'NAME': 'Maria Silva',
      'EMAIL': 'maria@example.com',
      'PHONE_NUMBER': '11999999999',
      'RESPONSIBLE_DOCUMENT': '***.***.***-4725',
      'STATUS': 'approved',
      'CREATED_AT': '2026-09-04T12:00:00Z',
    });
    expect(request.status, PharmacyAccessRequestStatus.approved);
    expect(request.pharmacyName, 'Farmacia Central');
  });
}
