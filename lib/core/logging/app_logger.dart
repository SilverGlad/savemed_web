import 'package:flutter/foundation.dart';

enum AppLogEvent {
  sessionRestoreFailed('session_restore_failed'),
  sessionAddressLoadFailed('session_address_load_failed'),
  homeInventoryLoadFailed('home_inventory_load_failed'),
  catalogSearchCompleted('catalog_search_completed'),
  paymentRequestFailed('payment_request_failed'),
  paymentStatusCheckFailed('payment_status_check_failed'),
  pharmacyAddressLoadFailed('pharmacy_address_load_failed'),
  inventoryLoadFailed('inventory_load_failed'),
  cardDataCleanupFailed('card_data_cleanup_failed');

  const AppLogEvent(this.key);

  final String key;
}

abstract final class AppLogger {
  static void event(AppLogEvent event) {
    if (!kDebugMode) return;
    debugPrint('[SaveMed] ${event.key}');
  }
}
