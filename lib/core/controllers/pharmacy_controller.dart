import 'package:flutter/material.dart';
import 'package:savemed/core/services/pharmacy_service.dart';
import 'package:savemed/core/logging/app_logger.dart';
import 'package:savemed/models/postal_address.dart';

class PharmacyController extends ChangeNotifier {
  final PharmacyService _service;
  int _addressGeneration = 0;

  PharmacyController({PharmacyService? service})
    : _service = service ?? PharmacyService();

  PostalAddress? pharmacyAddress;
  bool loadingAddress = false;
  int? addressPharmacyId;
  Object? addressError;

  @override
  void dispose() {
    _addressGeneration++;
    super.dispose();
  }

  Future<void> loadAddress(int pharmacyId) async {
    final generation = ++_addressGeneration;
    loadingAddress = true;
    pharmacyAddress = null;
    addressPharmacyId = pharmacyId;
    addressError = null;
    notifyListeners();

    try {
      final address = await _service.getPharmacyAddress(pharmacyId);
      if (generation != _addressGeneration) return;
      pharmacyAddress = address;
    } catch (error) {
      if (generation != _addressGeneration) return;
      addressError = error;
      AppLogger.event(AppLogEvent.pharmacyAddressLoadFailed);
    }

    loadingAddress = false;
    notifyListeners();
  }
}
