enum UserRole {
  customer('customer'),
  pharmacyAdmin('pharmacy_admin'),
  pharmacyUser('pharmacy_user'),
  appAdmin('app_admin'),
  unknown('unknown');

  final String apiValue;

  const UserRole(this.apiValue);

  bool get isAdmin => this == appAdmin || this == pharmacyAdmin;

  static UserRole fromApi(Object? value) {
    final role = value?.toString();
    return UserRole.values.firstWhere(
      (candidate) => candidate.apiValue == role,
      orElse: () => UserRole.unknown,
    );
  }
}
