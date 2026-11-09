enum PharmacyAccessRequestStatus {
  pending('pending', 'Pendente'),
  approved('approved', 'Aprovada'),
  rejected('rejected', 'Rejeitada'),
  cancelled('cancelled', 'Cancelada'),
  expired('expired', 'Expirada');

  final String apiValue;
  final String label;

  const PharmacyAccessRequestStatus(this.apiValue, this.label);

  static PharmacyAccessRequestStatus fromApi(Object? value) {
    final raw = value?.toString();
    return values.firstWhere(
      (status) => status.apiValue == raw,
      orElse: () => PharmacyAccessRequestStatus.pending,
    );
  }
}

class PharmacyAccessRequestSummary {
  final int id;
  final int pharmacyId;
  final String pharmacyName;
  final String responsibleName;
  final String email;
  final String phone;
  final String maskedDocument;
  final PharmacyAccessRequestStatus status;
  final String? decisionReason;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const PharmacyAccessRequestSummary({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.responsibleName,
    required this.email,
    required this.phone,
    required this.maskedDocument,
    required this.status,
    this.decisionReason,
    this.reviewedBy,
    this.reviewedAt,
    this.expiresAt,
    this.createdAt,
  });

  factory PharmacyAccessRequestSummary.fromJson(Map<String, dynamic> json) {
    final pharmacy = json['PHARMACY'] is Map<String, dynamic>
        ? json['PHARMACY'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return PharmacyAccessRequestSummary(
      id: _requiredInt(json['ID'], 'ID'),
      pharmacyId: _requiredInt(json['PHARMACY_ID'], 'PHARMACY_ID'),
      pharmacyName: pharmacy['NAME']?.toString() ?? 'Farmácia',
      responsibleName: json['NAME']?.toString() ?? '',
      email: json['EMAIL']?.toString() ?? '',
      phone: json['PHONE_NUMBER']?.toString() ?? '',
      maskedDocument: json['RESPONSIBLE_DOCUMENT']?.toString() ?? '',
      status: PharmacyAccessRequestStatus.fromApi(json['STATUS']),
      decisionReason: _optionalText(json['DECISION_REASON']),
      reviewedBy: _optionalInt(json['REVIEWED_BY']),
      reviewedAt: _optionalDate(json['REVIEWED_AT']),
      expiresAt: _optionalDate(json['EXPIRES_AT']),
      createdAt: _optionalDate(json['CREATED_AT']),
    );
  }

  static int _requiredInt(Object? value, String field) {
    final parsed = _optionalInt(value);
    if (parsed == null) throw FormatException('Invalid $field');
    return parsed;
  }

  static int? _optionalInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

  static String? _optionalText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static DateTime? _optionalDate(Object? value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toLocal();
}
