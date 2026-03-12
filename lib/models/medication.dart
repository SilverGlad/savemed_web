class Medication {
  static const String _imageBaseUrl =
      'https://bravelight.com.br/savemed/images/';

  final int id;
  final String name;
  final String description;
  final String? image;
  final int categoryId;
  final int subcategoryId;

  // ⚠️ exemplo de bool
  final bool requiresPrescription;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.categoryId,
    required this.subcategoryId,
    required this.requiresPrescription,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    final name = (json['NAME'] ?? '').toString();

    return Medication(
      id: json['ID'],
      name: name,
      description: json['DESCRIPTION'],
      image: _resolveImage(json['IMAGE'], name),
      categoryId: json['CATEGORY_ID'],
      subcategoryId: json['SUBCATEGORY_ID'],

      // 🔴 AQUI É O PONTO CRÍTICO
      requiresPrescription: json['REQUIRES_PRESCRIPTION'] ?? false,
    );
  }

  static String? _resolveImage(dynamic imageValue, String medicationName) {
    final raw = imageValue?.toString().trim();

    if (raw == null || raw.isEmpty) {
      if (medicationName.trim().isEmpty) return null;
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
}
