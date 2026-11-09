class ActiveIngredient {
  final int id;
  final String name;
  final int? pharmacyId;

  const ActiveIngredient({
    required this.id,
    required this.name,
    this.pharmacyId,
  });

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    final rawId = json['ID'] ?? json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final name = (json['NAME'] ?? json['name'])?.toString().trim() ?? '';
    if (id == null || name.isEmpty) {
      throw const FormatException(
        'Princípio ativo com dados obrigatórios inválidos.',
      );
    }
    final rawPharmacyId = json['PHARMACY_ID'] ?? json['pharmacyId'];
    final pharmacyId = rawPharmacyId is int
        ? rawPharmacyId
        : int.tryParse(rawPharmacyId?.toString() ?? '');
    return ActiveIngredient(id: id, name: name, pharmacyId: pharmacyId);
  }
}
