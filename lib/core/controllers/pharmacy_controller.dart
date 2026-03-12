import 'package:flutter/material.dart';
import 'package:SaveMed/core/services/pharmacy_service.dart';

class PharmacyController extends ChangeNotifier {
  final _service = PharmacyService();

  Map<String, dynamic>? pharmacyAddress;
  bool loadingAddress = false;

  Future<void> loadAddress(int pharmacyId) async {
    loadingAddress = true;
    notifyListeners();

    pharmacyAddress = await _service.getPharmacyAddress(pharmacyId);

    loadingAddress = false;
    notifyListeners();
  }
}
