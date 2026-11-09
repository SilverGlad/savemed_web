import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/pharmacy.dart';

void main() {
  test('parses administrative pharmacy fields without dynamic access', () {
    final pharmacy = Pharmacy.fromJson({
      'ID': '9',
      'NAME': 'Farmacia Central',
      'CNPJ': '04252011000110',
      'PHONE': '11999999999',
      'CITY': 'Sao Paulo',
      'STATE': 'SP',
      'ZIPCODE': '01001000',
      'ACCEPTS_OWN_DELIVERY': true,
      'ACCEPTS_PICKUP': false,
      'OWN_DELIVERY_PRICE': '8.50',
      'IS_ACTIVE': false,
      'INACTIVE_REASON': 'Cadastro em revisao',
    });

    expect(pharmacy.id, 9);
    expect(pharmacy.name, 'Farmacia Central');
    expect(pharmacy.addressLine, 'Sao Paulo - SP - 01001000');
    expect(pharmacy.ownDeliveryPrice, 8.5);
    expect(pharmacy.isActive, isFalse);
    expect(pharmacy.inactiveReason, 'Cadastro em revisao');
  });

  test('ignores non-finite optional delivery settings', () {
    final pharmacy = Pharmacy.fromJson({
      'ID': 9,
      'NAME': 'Farmacia Central',
      'OWN_DELIVERY_PRICE': 'Infinity',
      'OWN_DELIVERY_PRICE_PER_KM': double.nan,
      'OWN_DELIVERY_MAX_DISTANCE_KM': double.negativeInfinity,
    });

    expect(pharmacy.ownDeliveryPrice, isNull);
    expect(pharmacy.ownDeliveryPricePerKm, isNull);
    expect(pharmacy.ownDeliveryMaxDistanceKm, isNull);
  });
}
