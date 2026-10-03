import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/content_block.dart';

void main() {
  test('ContentBlock parses API fields and keeps image data', () {
    final block = ContentBlock.fromJson({
      'ID': 4,
      'SLUG': 'home-destaque',
      'EYEBROW': 'Entrega em Americana',
      'TITLE': 'Remédio sem pagar caro.',
      'SUBTITLE': 'Você compra no app.',
      'BODY': 'A SaveMed entrega.',
      'CTA_LABEL': 'Baixar o app',
      'CTA_URL': '/savemed/',
      'IMAGE': 'data:image/jpeg;base64,abc',
      'SORT_ORDER': 2,
      'IS_ACTIVE': true,
    });

    expect(block.id, 4);
    expect(block.slug, 'home-destaque');
    expect(block.eyebrow, 'Entrega em Americana');
    expect(block.ctaLabel, 'Baixar o app');
    expect(block.image, startsWith('data:image/jpeg'));
    expect(block.sortOrder, 2);
    expect(block.isActive, isTrue);
  });
}
