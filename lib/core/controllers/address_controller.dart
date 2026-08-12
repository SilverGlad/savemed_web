import 'package:flutter/material.dart';
import '../services/address_service.dart';

class AddressController extends ChangeNotifier {
  final _service = AddressService();

  bool loading = false;
  List<dynamic> addresses = [];

  Future<void> load(int userId) async {
    loading = true;
    notifyListeners();

    try {
      addresses = await _service.getUserAddresses(userId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Map<String, dynamic> data, int userId) async {
    await _service.createAddress(data);
    await load(userId);
  }

  Future<void> update(int id, Map<String, dynamic> data, int userId) async {
    await _service.updateAddress(id, data);
    await load(userId);
  }

  Future<void> remove(int id, int userId) async {
    await _service.deleteAddress(id);
    await load(userId);
  }
}
