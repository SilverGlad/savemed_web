import 'package:savemed/core/auth/user_role.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String? cpf;
  final String? phoneNumber;
  final UserRole role;
  final int? pharmacyId;
  final bool isActive;
  final bool mustChangePassword;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.cpf,
    this.phoneNumber,
    required this.role,
    this.pharmacyId,
    this.isActive = true,
    this.mustChangePassword = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['ID']);
    final name = json['NAME']?.toString().trim() ?? '';
    final email = json['EMAIL']?.toString().trim() ?? '';
    if (id == null || name.isEmpty || email.isEmpty) {
      throw const FormatException('Usuário com dados obrigatórios inválidos.');
    }

    return AppUser(
      id: id,
      name: name,
      email: email,
      cpf: _optionalString(json['CPF']),
      phoneNumber: _optionalString(json['PHONE_NUMBER']),
      role: UserRole.fromApi(json['USER_ROLE']),
      pharmacyId: _asInt(json['PHARMACY_ID']),
      isActive: json['IS_ACTIVE'] != false,
      mustChangePassword: json['MUST_CHANGE_PASSWORD'] == true,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class AuthSession {
  final String token;
  final AppUser user;

  const AuthSession({required this.token, required this.user});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString().trim() ?? '';
    final rawUser = json['user'];
    if (token.isEmpty || rawUser is! Map<String, dynamic>) {
      throw const FormatException('Sessão de autenticação inválida.');
    }
    return AuthSession(token: token, user: AppUser.fromJson(rawUser));
  }
}
