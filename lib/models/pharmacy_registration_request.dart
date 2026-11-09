class PharmacyRegistrationRequest {
  final String administratorName;
  final String email;
  final String password;
  final String cnpj;
  final String phone;
  final String pharmacyName;
  final String city;
  final String state;
  final String zipcode;

  const PharmacyRegistrationRequest({
    required this.administratorName,
    required this.email,
    required this.password,
    required this.cnpj,
    required this.phone,
    required this.pharmacyName,
    required this.city,
    required this.state,
    required this.zipcode,
  });

  String get normalizedCnpj => _digitsOnly(cnpj);
  String get normalizedPhone => _digitsOnly(phone);
  String get normalizedZipcode => _digitsOnly(zipcode);

  Map<String, dynamic> toJson() {
    return {
      'pharmacy': {
        'NAME': pharmacyName.trim(),
        'CNPJ': normalizedCnpj,
        'PHONE': normalizedPhone,
        'CITY': city.trim(),
        'STATE': state.trim().toUpperCase(),
        'ZIPCODE': normalizedZipcode,
      },
      'administrator': {
        'NAME': administratorName.trim(),
        'EMAIL': email.trim().toLowerCase(),
        'PASSWORD': password,
        'PHONE_NUMBER': normalizedPhone,
      },
    };
  }

  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');
}
