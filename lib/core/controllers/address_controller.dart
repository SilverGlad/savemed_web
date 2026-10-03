import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../../models/postal_address.dart';

class AddressController extends ChangeNotifier {
  final AddressService _service;
  int _loadGeneration = 0;
  int? _userId;

  AddressController({AddressService? service})
    : _service = service ?? AddressService();

  @override
  void dispose() {
    _loadGeneration++;
    super.dispose();
  }

  bool loading = false;
  Object? error;
  List<PostalAddress> addresses = [];

  void clear() {
    _loadGeneration++;
    _userId = null;
    addresses = [];
    error = null;
    loading = false;
    notifyListeners();
  }

  Future<void> load(int userId) async {
    final generation = ++_loadGeneration;
    if (_userId != userId) addresses = [];
    _userId = userId;
    error = null;
    loading = true;
    notifyListeners();

    try {
      final loaded = await _service.getUserAddresses(userId);
      if (generation != _loadGeneration) return;
      addresses = loaded;
    } catch (loadError) {
      if (generation == _loadGeneration) {
        error = loadError;
        rethrow;
      }
    } finally {
      if (generation == _loadGeneration) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> reloadForUi(int userId) async {
    try {
      await load(userId);
    } catch (_) {
      // The visible error state is retained by load; writes still propagate errors.
    }
  }

  Future<void> add(PostalAddress address, int userId) async {
    final generation = _loadGeneration;
    await _service.createAddress(address);
    if (generation != _loadGeneration) return;
    await load(userId);
  }

  Future<void> update(int id, PostalAddress address, int userId) async {
    final generation = _loadGeneration;
    await _service.updateAddress(id, address);
    if (generation != _loadGeneration) return;
    await load(userId);
  }

  Future<void> remove(int id, int userId) async {
    final generation = _loadGeneration;
    await _service.deleteAddress(id);
    if (generation != _loadGeneration) return;
    await load(userId);
  }
}
