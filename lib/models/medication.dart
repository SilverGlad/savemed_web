class Medication {
  static const String _imageBaseUrl =
      'https://bravelight.com.br/savemed/images/';

  final int id;
  final String name;
  final String description;
  final String? image;
  final int categoryId;
  final int? subcategoryId;

  // ⚠️ exemplo de bool
  final bool requiresPrescription;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.categoryId,
    this.subcategoryId,
    required this.requiresPrescription,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    final name = (json['NAME'] ?? '').toString();
    final id = _asInt(json['ID']);
    final categoryId = _asInt(json['CATEGORY_ID']);

    if (id == null || categoryId == null || name.trim().isEmpty) {
      throw const FormatException('Produto com dados obrigatorios invalidos.');
    }

    return Medication(
      id: id,
      name: name,
      description: (json['DESCRIPTION'] ?? '').toString(),
      image: _resolveImage(json['IMAGE'], name),
      categoryId: categoryId,
      subcategoryId: _asInt(json['SUBCATEGORY_ID']),

      // 🔴 AQUI É O PONTO CRÍTICO
      requiresPrescription:
          json['REQUIRES_RX'] == true || json['REQUIRES_PRESCRIPTION'] == true,
    );
  }

  static String? _resolveImage(dynamic imageValue, String medicationName) {
    final raw = imageValue?.toString().trim();

    if (raw == null || raw.isEmpty) {
      if (medicationName.trim().isEmpty) return null;
      return _buildImageUrl(medicationName);
    }

    if (imageValue is Map || imageValue is List) {
      return _buildImageUrl(medicationName);
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    return _buildImageUrl(raw);
  }

  static String _buildImageUrl(String fileOrName) {
    final normalized = fileOrName.trim();
    final encoded = Uri.encodeComponent(_withDefaultImageExtension(normalized));
    return '$_imageBaseUrl$encoded';
  }

  static String _withDefaultImageExtension(String value) {
    final lower = value.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return value;
    }
    return '$value.jpg';
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
