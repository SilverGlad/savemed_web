import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/financial_summary.dart';

void main() {
  test('normalizes non-finite financial values without exposing them', () {
    final summary = FinancialSummary.fromJson({
      'totalAmount': 'Infinity',
      'paidAmount': double.nan,
      'pendingAmount': double.negativeInfinity,
      'paidProductsAmount': 'NaN',
      'paidShippingAmount': double.infinity,
    });

    expect(summary.totalAmount, 0);
    expect(summary.paidAmount, 0);
    expect(summary.pendingAmount, 0);
    expect(summary.paidProductsAmount, isNull);
    expect(summary.paidShippingAmount, isNull);
  });
}
