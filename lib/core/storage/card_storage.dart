import 'package:shared_preferences/shared_preferences.dart';
import '../../models/payment_card.dart';

class CardStorage {
  static const _key = 'saved_payment_cards';
  static List<PaymentCard> _sessionCards = [];
  static int _generation = 0;

  /// Caches cards for this session without persisting PAN or CVV.
  static Future<void> save(List<PaymentCard> cards) async {
    final generation = _generation;
    final prefs = await SharedPreferences.getInstance();

    // Raw card details must never be persisted. Remove legacy stored payloads.
    await prefs.remove(_key);
    if (generation == _generation) _sessionCards = List.of(cards);
  }

  /// Returns session cards only and removes any legacy persisted payload.
  static Future<List<PaymentCard>> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return List.of(_sessionCards);
  }

  /// Clears in-memory session cards and the legacy persisted key.
  static Future<void> clear() async {
    clearSessionCards();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static void clearSessionCards() {
    _generation++;
    _sessionCards = [];
  }
}
