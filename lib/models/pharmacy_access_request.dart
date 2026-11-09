class PharmacyAccessRequest {
  final int pharmacyId;
  final String responsibleName;
  final String responsibleDocument;
  final String email;
  final String phone;

  const PharmacyAccessRequest({
    required this.pharmacyId,
    required this.responsibleName,
    required this.responsibleDocument,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'PHARMACY_ID': pharmacyId,
    'NAME': responsibleName.trim(),
    'RESPONSIBLE_DOCUMENT': _digitsOnly(responsibleDocument),
    'EMAIL': email.trim().toLowerCase(),
    'PHONE_NUMBER': _digitsOnly(phone),
  };

  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');
}
