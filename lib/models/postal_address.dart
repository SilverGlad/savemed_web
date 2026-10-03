class PostalAddress {
  final int? id;
  final String cep;
  final String street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String city;
  final String state;
  final bool isDefault;
  final Map<String, dynamic> _source;

  PostalAddress({
    this.id,
    required this.cep,
    required this.street,
    this.number,
    this.complement,
    this.neighborhood,
    required this.city,
    required this.state,
    this.isDefault = false,
    Map<String, dynamic> source = const {},
  }) : _source = Map.unmodifiable(source);

  factory PostalAddress.fromJson(Map<String, dynamic> json) {
    return PostalAddress(
      id: _parseId(json['ID'] ?? json['id']),
      cep: _readString(json, 'CEP', 'cep'),
      street: _readString(json, 'STREET', 'street'),
      number: _readOptionalString(json, 'NUMBER', 'number'),
      complement: _readOptionalString(json, 'COMPLEMENT', 'complement'),
      neighborhood: _readOptionalString(json, 'NEIGHBORHOOD', 'neighborhood'),
      city: _readString(json, 'CITY', 'city'),
      state: _readString(json, 'STATE', 'state'),
      isDefault: json['IS_DEFAULT'] == true || json['isDefault'] == true,
      source: json,
    );
  }

  Map<String, dynamic> toJson() => {
    ..._source,
    if (id != null) 'ID': id,
    'CEP': cep,
    'STREET': street,
    'NUMBER': number,
    'COMPLEMENT': complement,
    'NEIGHBORHOOD': neighborhood,
    'CITY': city,
    'STATE': state,
    'IS_DEFAULT': isDefault,
  };

  Map<String, dynamic> toShippingJson() =>
      _source.isEmpty ? toJson() : Map<String, dynamic>.of(_source);

  Map<String, dynamic> toRequestJson() => {
    'CEP': cep,
    'STREET': street,
    'NUMBER': number,
    'COMPLEMENT': complement,
    'NEIGHBORHOOD': neighborhood,
    'CITY': city,
    'STATE': state,
    'IS_DEFAULT': isDefault,
  };

  static int? _parseId(Object? value) => value is int
      ? value
      : value is String
      ? int.tryParse(value)
      : null;

  static String _readString(
    Map<String, dynamic> json,
    String upperKey,
    String lowerKey,
  ) => (json[upperKey] ?? json[lowerKey])?.toString() ?? '';

  static String? _readOptionalString(
    Map<String, dynamic> json,
    String upperKey,
    String lowerKey,
  ) {
    final value = json[upperKey] ?? json[lowerKey];
    return value?.toString();
  }
}
