import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/services/address_service.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/models/postal_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../support/in_memory_token_vault.dart';

void main() {
  setUp(() {
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  for (final action in ['add', 'update', 'remove']) {
    test(
      '$action finishing after clear does not reload the old account',
      () async {
        final service = _Service();
        final controller = AddressController(service: service);
        addTearDown(controller.dispose);
        final pending = switch (action) {
          'add' => controller.add(_address(), 1),
          'update' => controller.update(1, _address(), 1),
          _ => controller.remove(1, 1),
        };
        controller.clear();
        service.write.complete();
        await pending;
        expect(service.requests, isEmpty);
        expect(controller.addresses, isEmpty);
      },
    );
  }
  for (final expired in [false, true]) {
    test(
      'session exit clears addresses and ignores pending load (expired: $expired)',
      () async {
        SharedPreferences.setMockInitialValues({});
        final service = _Service();
        final addresses = AddressController(service: service);
        final auth = AuthController();
        addTearDown(addresses.dispose);
        addTearDown(auth.dispose);
        await auth.restoreSession(addresses);
        final initial = addresses.load(1);
        service.requests.last.complete([
          {'ID': 1},
        ]);
        await initial;
        final pending = addresses.load(1);
        if (expired) {
          await auth.expireSession();
        } else {
          await auth.logout();
        }
        expect(addresses.addresses, isEmpty);
        expect(addresses.loading, isFalse);
        expect(addresses.error, isNull);
        service.requests.last.complete([
          {'ID': 2},
        ]);
        await pending;
        expect(addresses.addresses, isEmpty);
      },
    );
  }
  test(
    'UI retry retains same-account data and clears error after recovery',
    () async {
      final service = _Service();
      final controller = AddressController(service: service);
      addTearDown(controller.dispose);
      final first = controller.reloadForUi(1);
      service.requests.last.complete([
        {'ID': 1},
      ]);
      await first;
      final failed = controller.reloadForUi(1);
      service.requests.last.completeError(Exception('offline'));
      await failed;
      expect(controller.error, isNotNull);
      expect(controller.addresses.single.id, 1);
      expect(controller.loading, isFalse);
      final retry = controller.reloadForUi(1);
      expect(controller.error, isNull);
      service.requests.last.complete([
        {'ID': 2},
      ]);
      await retry;
      expect(controller.addresses.single.id, 2);
      expect(controller.error, isNull);
    },
  );
  for (final fails in [false, true]) {
    test(
      'old account load cannot overwrite current addresses (fails: $fails)',
      () async {
        final service = _Service();
        final controller = AddressController(service: service);
        addTearDown(controller.dispose);
        final old = controller.load(1);
        final current = controller.load(2);
        service.requests[1].complete([
          {'ID': 2},
        ]);
        await current;
        if (fails) {
          service.requests[0].completeError(Exception('old failure'));
        } else {
          service.requests[0].complete([
            {'ID': 1},
          ]);
        }
        await old;
        expect(controller.addresses.single.id, 2);
        expect(controller.loading, isFalse);
      },
    );
  }

  test(
    'new account clears prior addresses and current failure still propagates',
    () async {
      final service = _Service();
      final controller = AddressController(service: service);
      addTearDown(controller.dispose);
      final first = controller.load(1);
      service.requests[0].complete([
        {'ID': 1},
      ]);
      await first;
      final next = controller.load(2);
      expect(controller.addresses, isEmpty);
      final failure = expectLater(next, throwsException);
      service.requests[1].completeError(Exception('current failure'));
      await failure;
      expect(controller.loading, isFalse);
      expect(controller.addresses, isEmpty);
    },
  );

  test('late response after disposal is ignored', () async {
    final service = _Service();
    final controller = AddressController(service: service);
    final request = controller.load(1);
    controller.dispose();
    service.requests.single.complete([
      {'ID': 1},
    ]);
    await request;
    expect(controller.addresses, isEmpty);
  });
}

PostalAddress _address() => PostalAddress(
  cep: '01001000',
  street: 'Rua Teste',
  city: 'Sao Paulo',
  state: 'SP',
);

class _Service extends AddressService {
  final write = Completer<void>();
  @override
  Future<void> createAddress(PostalAddress address) => write.future;
  @override
  Future<void> updateAddress(int id, PostalAddress address) => write.future;
  @override
  Future<void> deleteAddress(int id) => write.future;
  final requests = <Completer<List<Map<String, dynamic>>>>[];
  @override
  Future<List<PostalAddress>> getUserAddresses(int userId) {
    final request = Completer<List<Map<String, dynamic>>>();
    requests.add(request);
    return request.future.then(
      (addresses) => addresses.map(PostalAddress.fromJson).toList(),
    );
  }
}
