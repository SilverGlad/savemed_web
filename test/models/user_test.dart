import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/models/user.dart';

void main() {
  test('parses a typed authenticated user and session', () {
    final session = AuthSession.fromJson({
      'token': 'token-value',
      'user': {
        'ID': '12',
        'NAME': 'Maria Silva',
        'EMAIL': 'maria@example.com',
        'CPF': '52998224725',
        'PHONE_NUMBER': '11999999999',
        'USER_ROLE': 'pharmacy_admin',
        'PHARMACY_ID': '9',
        'IS_ACTIVE': true,
        'MUST_CHANGE_PASSWORD': false,
      },
    });

    expect(session.token, 'token-value');
    expect(session.user.id, 12);
    expect(session.user.role, UserRole.pharmacyAdmin);
    expect(session.user.pharmacyId, 9);
    expect(session.user.isActive, isTrue);
  });

  test('rejects an incomplete authentication boundary', () {
    expect(
      () => AuthSession.fromJson({'token': '', 'user': {}}),
      throwsFormatException,
    );
    expect(
      () => AppUser.fromJson({'ID': 1, 'NAME': '', 'EMAIL': ''}),
      throwsFormatException,
    );
  });
}
