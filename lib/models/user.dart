class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? pharmacyId;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.pharmacyId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['ID'],
      name: json['NAME'],
      email: json['EMAIL'],
      role: json['USER_ROLE'],
      pharmacyId: json['PHARMACY_ID'],
    );
  }
}
