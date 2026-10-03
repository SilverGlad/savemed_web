import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/order_fulfillment.dart';

void main() {
  test('normalizes non-finite fulfillment amounts', () {
    final fulfillment = OrderFulfillment({
      'total': double.nan,
      'shippingPrice': 'Infinity',
      'fulfillment': {
        'mode': 'pedmoto',
        'pedmoto': {'estimatedPrice': double.negativeInfinity},
      },
    });

    expect(fulfillment.total, 0);
    expect(fulfillment.shippingPrice, 0);
    expect(fulfillment.pedMotoPrice, 0);
  });
}
