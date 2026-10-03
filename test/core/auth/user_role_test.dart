import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/auth/user_role.dart';

void main() {
  test('parses API roles and identifies administrative access', () {
    expect(UserRole.fromApi('customer'), UserRole.customer);
    expect(UserRole.fromApi('pharmacy_admin').isAdmin, isTrue);
    expect(UserRole.fromApi('pharmacy_user'), UserRole.pharmacyUser);
    expect(UserRole.pharmacyUser.isAdmin, isFalse);
    expect(UserRole.fromApi('app_admin').isAdmin, isTrue);
    expect(UserRole.fromApi('unexpected'), UserRole.unknown);
    expect(UserRole.unknown.isAdmin, isFalse);
  });
}
