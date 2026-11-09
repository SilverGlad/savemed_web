class PharmacySearchResult {
  final int id;
  final String name;
  final String? maskedCnpj;
  final String? city;
  final String? state;

  const PharmacySearchResult({
    required this.id,
    required this.name,
    this.maskedCnpj,
    this.city,
    this.state,
  });

  factory PharmacySearchResult.fromJson(Map<String, dynamic> json) {
    final rawId = json['ID'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final name = json['NAME']?.toString().trim() ?? '';
    if (id == null || name.isEmpty) {
      throw const FormatException('Invalid pharmacy search result');
    }
    return PharmacySearchResult(
      id: id,
      name: name,
      maskedCnpj: _optionalText(json['CNPJ_MASKED']),
      city: _optionalText(json['CITY']),
      state: _optionalText(json['STATE']),
    );
  }

  String get location {
    final parts = [
      city,
      state,
    ].whereType<String>().where((item) => item.isNotEmpty);
    return parts.join(' - ');
  }

  static String? _optionalText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
