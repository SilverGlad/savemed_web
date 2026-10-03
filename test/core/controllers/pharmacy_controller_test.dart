import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/controllers/pharmacy_controller.dart';
import 'package:savemed/core/services/pharmacy_service.dart';
import 'package:savemed/models/postal_address.dart';

void main() {
  test('failed address load stops waiting and can be retried', () async {
    final service = _Service();
    final controller = PharmacyController(service: service);
    addTearDown(controller.dispose);
    final first = controller.loadAddress(1);
    expect(controller.loadingAddress, isTrue);
    service.requests.last.completeError(Exception('offline'));
    await first;
    expect(controller.loadingAddress, isFalse);
    expect(controller.addressError, isNotNull);
    expect(controller.pharmacyAddress, isNull);
    final retry = controller.loadAddress(1);
    expect(controller.addressError, isNull);
    service.requests.last.complete({'CEP': '01001000'});
    await retry;
    expect(controller.pharmacyAddress?.cep, '01001000');
    expect(controller.addressPharmacyId, 1);
    expect(controller.loadingAddress, isFalse);
  });

  for (final fails in [false, true]) {
    test(
      'old pharmacy response cannot replace current address (fails: $fails)',
      () async {
        final service = _Service();
        final controller = PharmacyController(service: service);
        addTearDown(controller.dispose);
        final old = controller.loadAddress(1);
        final current = controller.loadAddress(2);
        expect(controller.pharmacyAddress, isNull);
        service.requests[1].complete({'CEP': '22222222'});
        await current;
        if (fails) {
          service.requests[0].completeError(Exception('old failure'));
        } else {
          service.requests[0].complete({'CEP': '11111111'});
        }
        await old;
        expect(controller.addressPharmacyId, 2);
        expect(controller.pharmacyAddress?.cep, '22222222');
        expect(controller.addressError, isNull);
        expect(controller.loadingAddress, isFalse);
      },
    );
  }

  test('disposed controller ignores late address completion', () async {
    final service = _Service();
    final controller = PharmacyController(service: service);
    final request = controller.loadAddress(1);
    controller.dispose();
    service.requests.single.complete({'CEP': '01001000'});
    await request;
    expect(controller.pharmacyAddress, isNull);
  });
}

class _Service extends PharmacyService {
  final requests = <Completer<Map<String, dynamic>>>[];
  @override
  Future<PostalAddress> getPharmacyAddress(int pharmacyId) {
    final request = Completer<Map<String, dynamic>>();
    requests.add(request);
    return request.future.then(PostalAddress.fromJson);
  }
}
