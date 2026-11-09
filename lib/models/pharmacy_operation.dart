class PharmacyOperation {
  final int id;
  final int version;
  final bool active;
  final bool isOpen;
  final int? preparationMinutes;
  final int? payoutTermDays;
  const PharmacyOperation({
    required this.id,
    required this.version,
    required this.active,
    required this.isOpen,
    this.preparationMinutes,
    this.payoutTermDays,
  });

  factory PharmacyOperation.fromJson(Map<String, dynamic> json) =>
      PharmacyOperation(
        id: (json['id'] as num).toInt(),
        version: (json['version'] as num).toInt(),
        active: json['active'] == true,
        isOpen: json['isOpen'] == true,
        preparationMinutes: (json['preparationMinutes'] as num?)?.toInt(),
        payoutTermDays: (json['payoutTermDays'] as num?)?.toInt(),
      );
}
