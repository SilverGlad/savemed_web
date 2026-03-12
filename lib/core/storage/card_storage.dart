import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/payment_card.dart';

class CardStorage {
  static const _key = 'saved_payment_cards';

  /// 🔹 Salva lista de cartões
  static Future<void> save(List<PaymentCard> cards) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = cards.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// 🔹 Carrega cartões
  static Future<List<PaymentCard>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return [];

    final List list = jsonDecode(raw);
    return list.map((e) => PaymentCard.fromJson(e)).toList();
  }

  /// 🔹 Limpa todos os cartões (opcional)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
