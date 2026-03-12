import 'package:flutter/material.dart';
import '../../models/payment_card.dart';
import '../storage/card_storage.dart';

class CardController extends ChangeNotifier {
  final List<PaymentCard> cards = [];
  PaymentCard? selected;
  bool loading = false;

  Future<void> loadCards() async {
    loading = true;
    notifyListeners();

    final stored = await CardStorage.load();
    cards
      ..clear()
      ..addAll(stored);

    loading = false;
    notifyListeners();
  }

  Future<void> addCard(PaymentCard card) async {
    cards.add(card);
    selected ??= card;

    await CardStorage.save(cards);
    notifyListeners();
  }

  Future<void> removeCard(PaymentCard card) async {
    cards.removeWhere((c) => c.id == card.id);

    if (selected?.id == card.id) {
      selected = cards.isNotEmpty ? cards.first : null;
    }

    await CardStorage.save(cards);
    notifyListeners();
  }

  void select(PaymentCard card) {
    selected = card;
    notifyListeners();
  }
}
