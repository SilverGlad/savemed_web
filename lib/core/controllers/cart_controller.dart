import 'package:savemed/core/services/shipping_service.dart';
import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../models/inventory_item.dart';
import '../../models/postal_address.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];
  final ShippingService _shippingService;
  int _shippingGeneration = 0;
  int _shippingInputRevision = 0;
  int get shippingInputRevision => _shippingInputRevision;

  CartController({ShippingService? shippingService})
    : _shippingService = shippingService ?? ShippingService();

  @override
  void dispose() {
    _shippingGeneration++;
    super.dispose();
  }

  void _invalidateShipping({bool preservePickup = false}) {
    _shippingGeneration++;
    _shippingInputRevision++;
    _loadingShipping = false;
    _shippingOptions = [];
    if (!preservePickup || !isPickupSelected) _selectedShipping = null;
    _shippingError = null;
  }

  PostalAddress? _selectedAddress;
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
        'company': {'name': _pharmacyName ?? 'Farmácia'},
        'name': 'Retirar no local',
        'delivery_time': null,
        'price': 0.0,
        'description': 'Retirada diretamente na farmácia.',
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

    final generation = ++_shippingGeneration;
    _loadingShipping = true;
    _shippingOptions = [];
    if (!isPickupSelected) _selectedShipping = null;
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

      final options = await _shippingService.quote(
        pharmacyId: _pharmacyId!,
        fromCep: fromCep,
        toCep: _selectedAddress!.cep,
        destinationAddress: _selectedAddress!.toShippingJson(),
        products: products,
      );
      if (generation != _shippingGeneration) return;
      _shippingOptions = options;
    } on ShippingQuoteException catch (error) {
      if (generation != _shippingGeneration) return;
      _shippingError = error.message;
      _shippingOptions = [];
    } catch (_) {
      if (generation != _shippingGeneration) return;
      _shippingError = 'Não foi possível calcular o frete agora.';
      _shippingOptions = [];
    }

    _loadingShipping = false;
    notifyListeners();
  }

  List<CartItem> get items => _items;
  PostalAddress? get selectedAddress => _selectedAddress;
  int? get pharmacyId => _pharmacyId;
  String? get pharmacyName => _pharmacyName;
  bool get hasPharmacy => _pharmacyId != null;

  double get subtotal =>
      _items.fold(0, (sum, e) => sum + e.item.price * e.quantity);

  int get totalItems => _items.fold(0, (sum, e) => sum + e.quantity);

  double get total =>
      _items.fold(0, (sum, e) => sum + (e.item.price * e.quantity));

  void selectAddress(PostalAddress address) {
    _invalidateShipping();
    _selectedAddress = address;
    notifyListeners();
  }

  void clearAddress() {
    _invalidateShipping();
    _selectedAddress = null;
    notifyListeners();
  }

  bool canAddItem(InventoryItem item) {
    if (_pharmacyId == null) return true;
    return item.pharmacy.id == _pharmacyId;
  }

  bool addItem(InventoryItem item) {
    if (!item.available || !canAddItem(item)) return false;
    final index = _items.indexWhere((e) => e.item.id == item.id);
    if (index >= 0 && _items[index].quantity >= item.stock) return false;
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

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(item: item));
    }

    _invalidateShipping(preservePickup: true);
    notifyListeners();
    return true;
  }

  bool canIncrease(CartItem cartItem) =>
      _items.contains(cartItem) &&
      cartItem.item.available &&
      cartItem.quantity < cartItem.item.stock;

  void increase(CartItem cartItem) {
    if (!canIncrease(cartItem)) return;
    cartItem.quantity++;
    _invalidateShipping(preservePickup: true);
    notifyListeners();
  }

  void decrease(CartItem cartItem) {
    _invalidateShipping(preservePickup: true);
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
    _invalidateShipping(preservePickup: true);
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
    _invalidateShipping();
    _selectedAddress = null;
    _pharmacyId = null;
    _pharmacyName = null;
    _acceptsOwnDelivery = false;
    _acceptsPickup = false;
    _ownDeliveryPrice = null;
    _ownDeliveryPricePerKm = null;
    _ownDeliveryMaxDistanceKm = null;
    _ownDeliveryNote = null;
  }
}
