import 'package:savemed/core/services/shipping_service.dart';
import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../models/inventory_item.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];
  final ShippingService _shippingService = ShippingService();

  Map<String, dynamic>? _selectedAddress;
  int? _pharmacyId;
  String? _pharmacyName;
  bool _acceptsOwnDelivery = false;
  bool _acceptsPickup = false;
  double? _ownDeliveryPrice;
  double? _ownDeliveryPricePerKm;
  double? _ownDeliveryMaxDistanceKm;
  String? _ownDeliveryNote;
  List<Map<String, dynamic>> _shippingOptions = [];
  Map<String, dynamic>? _selectedShipping;
  bool _loadingShipping = false;
  String? _shippingError;

  List<Map<String, dynamic>> get shippingOptions => _shippingOptions;
  Map<String, dynamic>? get selectedShipping => _selectedShipping;
  bool get loadingShipping => _loadingShipping;
  String? get shippingError => _shippingError;
  bool get acceptsOwnDelivery => _acceptsOwnDelivery;
  bool get acceptsPickup => _acceptsPickup;
  double? get ownDeliveryPrice => _ownDeliveryPrice;
  double? get ownDeliveryPricePerKm => _ownDeliveryPricePerKm;
  double? get ownDeliveryMaxDistanceKm => _ownDeliveryMaxDistanceKm;
  String? get ownDeliveryNote => _ownDeliveryNote;
  bool get isPickupSelected => _selectedShipping?['method'] == 'pickup';
  bool get needsDeliveryAddress => !isPickupSelected;

  List<Map<String, dynamic>> get localDeliveryOptions {
    final options = <Map<String, dynamic>>[];

    if (_acceptsPickup) {
      options.add({
        'id': 'pickup',
        'method': 'pickup',
        'company': {'name': _pharmacyName ?? 'Farmacia'},
        'name': 'Retirar no local',
        'delivery_time': null,
        'price': 0.0,
        'description': 'Retirada diretamente na farmacia.',
      });
    }

    return options;
  }

  void selectShipping(Map<String, dynamic> option) {
    _selectedShipping = {
      ...option,
      'price': double.tryParse(option['price'].toString()) ?? 0.0,
    };
    notifyListeners();
  }

  Future<void> calculateShipping(String fromCep) async {
    if (_selectedAddress == null || _items.isEmpty || _pharmacyId == null) {
      return;
    }

    _loadingShipping = true;
    _shippingOptions = [];
    _selectedShipping = null;
    _shippingError = null;
    notifyListeners();

    try {
      final totalQuantity = _items.fold<int>(0, (sum, e) => sum + e.quantity);

      const double weightPerItem = 0.15;
      const double packageWeight = 0.30;

      final totalWeight = packageWeight + (totalQuantity * weightPerItem);

      final insuranceValue = _items.fold<double>(
        0,
        (sum, e) => sum + (e.item.price * e.quantity),
      );

      final products = [
        {
          'id': 'box-1',
          'quantity': 1,
          'weight': totalWeight,
          'width': 20,
          'height': 15,
          'length': 20,
          'insurance_value': insuranceValue,
        },
      ];

      _shippingOptions = await _shippingService.quote(
        pharmacyId: _pharmacyId!,
        fromCep: fromCep,
        toCep: _selectedAddress!['CEP'],
        destinationAddress: _selectedAddress!,
        products: products,
      );
    } on ShippingQuoteException catch (error) {
      _shippingError = error.message;
      _shippingOptions = [];
    } catch (_) {
      _shippingError = 'Nao foi possivel calcular o frete agora.';
      _shippingOptions = [];
    }

    _loadingShipping = false;
    notifyListeners();
  }

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

  void selectAddress(Map<String, dynamic> address) {
    _selectedAddress = address;
    _selectedShipping = null;
    _shippingOptions = [];
    _shippingError = null;
    notifyListeners();
  }

  void clearAddress() {
    _selectedAddress = null;
    _shippingError = null;
    notifyListeners();
  }

  bool canAddItem(InventoryItem item) {
    if (_pharmacyId == null) return true;
    return item.pharmacy.id == _pharmacyId;
  }

  void addItem(InventoryItem item) {
    if (_pharmacyId == null) {
      _pharmacyId = item.pharmacy.id;
      _pharmacyName = item.pharmacy.name;
      _acceptsOwnDelivery = item.pharmacy.acceptsOwnDelivery;
      _acceptsPickup = item.pharmacy.acceptsPickup;
      _ownDeliveryPrice = item.pharmacy.ownDeliveryPrice;
      _ownDeliveryPricePerKm = item.pharmacy.ownDeliveryPricePerKm;
      _ownDeliveryMaxDistanceKm = item.pharmacy.ownDeliveryMaxDistanceKm;
      _ownDeliveryNote = item.pharmacy.ownDeliveryNote;
    }

    final index = _items.indexWhere((e) => e.item.id == item.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(item: item));
    }

    notifyListeners();
  }

  void increase(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  void decrease(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _items.remove(cartItem);

      if (_items.isEmpty) {
        _resetOperationalState();
      }
    }

    notifyListeners();
  }

  void remove(CartItem cartItem) {
    _items.remove(cartItem);

    if (_items.isEmpty) {
      _resetOperationalState();
    }

    notifyListeners();
  }

  void clear() {
    _items.clear();
    _resetOperationalState();
    notifyListeners();
  }

  void _resetOperationalState() {
    _selectedAddress = null;
    _pharmacyId = null;
    _pharmacyName = null;
    _acceptsOwnDelivery = false;
    _acceptsPickup = false;
    _ownDeliveryPrice = null;
    _ownDeliveryPricePerKm = null;
    _ownDeliveryMaxDistanceKm = null;
    _ownDeliveryNote = null;
    _shippingOptions = [];
    _selectedShipping = null;
    _shippingError = null;
  }
}
