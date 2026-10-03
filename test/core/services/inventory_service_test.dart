import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:savemed/core/services/inventory_service.dart';
import 'package:savemed/models/pharmacy.dart';

void main() {
  test(
    'loads a store inventory when its route omits pharmacy details',
    () async {
      String? requestedPath;
      final service = InventoryService(
        get: (path, {query}) async {
          requestedPath = path;
          return http.Response(
            jsonEncode([
              {
                'ID': 12,
                'PRICE': 19.9,
                'ORIGINAL_PRICE': 22,
                'STOCK': 2,
                'Medication': {
                  'ID': 14,
                  'NAME': 'Protetor Solar',
                  'DESCRIPTION': 'FPS 50',
                  'CATEGORY_ID': 3,
                },
              },
            ]),
            200,
          );
        },
      );
      const pharmacy = Pharmacy(id: 7, name: 'Farmácia Central', isOpen: false);

      final items = await service.getInventoryForPharmacy(pharmacy);

      expect(requestedPath, '/inventory/pharmacy/7');
      expect(items, hasLength(1));
      expect(items.single.pharmacy, same(pharmacy));
      expect(items.single.available, isFalse);
      expect(items.single.unavailableLabel, 'Loja fechada');
    },
  );
}
