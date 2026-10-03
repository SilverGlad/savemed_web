import 'package:savemed/core/api/api_client.dart';

class ContentBlock {
  final int id;
  final String slug;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String body;
  final String ctaLabel;
  final String ctaUrl;
  final String? image;
  final int sortOrder;
  final bool isActive;

  const ContentBlock({
    required this.id,
    required this.slug,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.ctaLabel,
    required this.ctaUrl,
    required this.image,
    required this.sortOrder,
    required this.isActive,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final rawImage =
        json['IMAGE_URL'] ?? json['imageUrl'] ?? json['IMAGE'] ?? json['image'];
    return ContentBlock(
      id: int.tryParse('${json['ID'] ?? json['id']}') ?? 0,
      slug: '${json['SLUG'] ?? json['slug'] ?? ''}',
      eyebrow: '${json['EYEBROW'] ?? json['eyebrow'] ?? ''}',
      title: '${json['TITLE'] ?? json['title'] ?? ''}',
      subtitle: '${json['SUBTITLE'] ?? json['subtitle'] ?? ''}',
      body: '${json['BODY'] ?? json['body'] ?? ''}',
      ctaLabel: '${json['CTA_LABEL'] ?? json['ctaLabel'] ?? ''}',
      ctaUrl: '${json['CTA_URL'] ?? json['ctaUrl'] ?? ''}',
      image: _resolveImage(rawImage),
      sortOrder:
          int.tryParse('${json['SORT_ORDER'] ?? json['sortOrder']}') ?? 0,
      isActive: json['IS_ACTIVE'] != false && json['isActive'] != false,
    );
  }

  static String? _resolveImage(Object? value) {
    if (value is! String || value.isEmpty || value == 'false') return null;
    if (value.startsWith('data:') || value.startsWith('http')) return value;
    if (value.startsWith('/api/')) {
      final origin = ApiClient.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
      return '$origin$value';
    }
    return '${ApiClient.baseUrl}${value.startsWith('/') ? value : '/$value'}';
  }
}
