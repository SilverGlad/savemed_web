import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/logging/app_logger.dart';

void main() {
  test('logs only stable keys for allowlisted events', () {
    final messages = <String?>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message);
    addTearDown(() => debugPrint = originalDebugPrint);

    const expectedKeys = [
      'session_restore_failed',
      'session_address_load_failed',
      'home_inventory_load_failed',
      'catalog_search_completed',
      'payment_request_failed',
      'payment_status_check_failed',
      'pharmacy_address_load_failed',
      'inventory_load_failed',
      'card_data_cleanup_failed',
    ];
    expect(AppLogEvent.values.map((event) => event.key).toList(), expectedKeys);

    for (final event in AppLogEvent.values) {
      AppLogger.event(event);
    }

    expect(messages, expectedKeys.map((key) => '[SaveMed] $key').toList());
  });
}
