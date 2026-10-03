import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/models/active_ingredient.dart';

void main() {
  group('ActiveIngredient.fromJson', () {
    test('accepts the API uppercase contract', () {
      final ingredient = ActiveIngredient.fromJson({
        'ID': '42',
        'NAME': 'Dipirona',
        'PHARMACY_ID': '12',
      });

      expect(ingredient.id, 42);
      expect(ingredient.name, 'Dipirona');
      expect(ingredient.pharmacyId, 12);
    });

    test('accepts lowercase aliases and rejects incomplete data', () {
      final ingredient = ActiveIngredient.fromJson({
        'id': 7,
        'name': 'Cafeina',
      });

      expect(ingredient.id, 7);
      expect(ingredient.name, 'Cafeina');
      expect(
        () => ActiveIngredient.fromJson({'ID': 8, 'NAME': ' '}),
        throwsFormatException,
      );
    });
  });
}
