import 'package:flutter/material.dart';
import 'package:SaveMed/core/services/shipping_service.dart';
import '../../models/cart_item.dart';
import '../../models/inventory_item.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];
  final ShippingService _shippingService = ShippingService();

  Map<String, dynamic>? _selectedAddress;
  int? _pharmacyId;
  String? _pharmacyName;
  List<Map<String, dynamic>> _shippingOptions = [];
  Map<String, dynamic>? _selectedShipping;
  bool _loadingShipping = false;

  List<Map<String, dynamic>> get shippingOptions => _shippingOptions;
  Map<String, dynamic>? get selectedShipping => _selectedShipping;
  bool get loadingShipping => _loadingShipping;

  void selectShipping(Map<String, dynamic> option) {
    _selectedShipping = {
      ...option,
      'price': double.tryParse(option['price'].toString()) ?? 0.0,
    };
    notifyListeners();
  }

  Future<void> calculateShipping(String fromCep) async {
    if (_selectedAddress == null || _items.isEmpty) return;

    _loadingShipping = true;
    _shippingOptions = [];
    _selectedShipping = null;
    notifyListeners();

    try {
      final totalQuantity = _items.fold<int>(0, (sum, e) => sum + e.quantity);

      const double weightPerItem = 0.15;
      const double packageWeight = 0.30;

      final double totalWeight =
          packageWeight + (totalQuantity * weightPerItem);

      final double insuranceValue = _items.fold<double>(
        0,
        (sum, e) => sum + (e.item.price * e.quantity),
      );

      final products = [
        {
          "id": "box-1",
          "quantity": 1,
          "weight": totalWeight,
          "width": 20,
          "height": 15,
          "length": 20,
          "insurance_value": insuranceValue,
        },
      ];

      _shippingOptions = await _shippingService.quote(
        fromCep: fromCep,
        toCep: _selectedAddress!['CEP'],
        products: products,
      );
    } catch (_) {
      _shippingOptions = [];
    }

    _loadingShipping = false;
    notifyListeners();
  }

  // =====================
  // GETTERS
  // =====================
  List<CartItem> get items => _items;

  Map<String, dynamic>? get selectedAddress => _selectedAddress;

  int? get pharmacyId => _pharmacyId;
  String? get pharmacyName => _pharmacyName;

  bool get hasPharmacy => _pharmacyId != null;

  double get subtotal =>
      _items.fold(0, (sum, e) => sum + e.item.price * e.quantity);

  int get totalItems => _items.fold(0, (sum, e) => sum + e.quantity);

  double get total =>
      _items.fold(0, (sum, e) => sum + (e.item.price * e.quantity));

  // =====================
  // ENDEREÇO
  // =====================
  void selectAddress(Map<String, dynamic> address) {
    _selectedAddress = address;
    _selectedShipping = null;
    _shippingOptions = [];
    notifyListeners();
  }

  void clearAddress() {
    _selectedAddress = null;
    notifyListeners();
  }

  // =====================
  // FARMÁCIA
  // =====================
  bool canAddItem(InventoryItem item) {
    if (_pharmacyId == null) return true;
    return item.pharmacy.id == _pharmacyId;
  }

  // =====================
  // ADD
  // =====================
  void addItem(InventoryItem item) {
    if (_pharmacyId == null) {
      _pharmacyId = item.pharmacy.id;
      _pharmacyName = item.pharmacy.name;
    }

    final index = _items.indexWhere((e) => e.item.id == item.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(item: item));
    }

    notifyListeners();
  }

  // =====================
  // INCREASE
  // =====================
  void increase(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  // =====================
  // DECREASE
  // =====================
  void decrease(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _items.remove(cartItem);

      // 🧹 Se esvaziou, limpa tudo
      if (_items.isEmpty) {
        _pharmacyId = null;
        _selectedAddress = null;
      }
    }

    notifyListeners();
  }

  // =====================
  // REMOVE
  // =====================
  void remove(CartItem cartItem) {
    _items.remove(cartItem);

    if (_items.isEmpty) {
      _pharmacyId = null;
      _selectedAddress = null;
    }

    notifyListeners();
  }

  // =====================
  // CLEAR CART
  // =====================
  void clear() {
    _items.clear();
    _selectedAddress = null;
    _pharmacyId = null;
    _pharmacyName = null;
    notifyListeners();
  }
}
