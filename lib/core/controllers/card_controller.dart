import 'package:flutter/material.dart';
import '../../models/payment_card.dart';
import '../storage/card_storage.dart';

class CardController extends ChangeNotifier {
  final List<PaymentCard> cards = [];
  PaymentCard? selected;
  bool loading = false;
  int _generation = 0;

  void clear() {
    _clearSessionData();
    notifyListeners();
  }

  /// Clears route-scoped data without notifying listeners during route disposal.
  void clearForRouteExit() {
    _clearSessionData();
  }

  /// Clears startup state without notifying listeners during the build phase.
  void clearForSessionRestore() {
    _clearSessionData();
  }

  void _clearSessionData() {
    _generation++;
    cards.clear();
    selected = null;
    loading = false;
    CardStorage.clearSessionCards();
  }

  @override
  void dispose() {
    _generation++;
    cards.clear();
    selected = null;
    loading = false;
    CardStorage.clearSessionCards();
    super.dispose();
  }

  Future<void> loadCards() async {
    final generation = ++_generation;
    loading = true;
    notifyListeners();

    try {
      final stored = await CardStorage.load();
      if (generation != _generation) return;
      cards
        ..clear()
        ..addAll(stored);
      selected =
          cards.where((card) => card.id == selected?.id).firstOrNull ??
          cards.firstOrNull;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addCard(PaymentCard card) async {
    final generation = _generation;
    cards.add(card);
    selected ??= card;

    await CardStorage.save(cards);
    if (generation == _generation) notifyListeners();
  }

  Future<void> removeCard(PaymentCard card) async {
    final generation = _generation;
    cards.removeWhere((c) => c.id == card.id);

    if (selected?.id == card.id) {
      selected = cards.isNotEmpty ? cards.first : null;
    }

    await CardStorage.save(cards);
    if (generation == _generation) notifyListeners();
  }

  void select(PaymentCard card) {
    selected = card;
    notifyListeners();
  }
}
