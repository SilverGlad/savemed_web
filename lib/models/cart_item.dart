import 'package:savemed/models/inventory_item.dart';

class CartItem {
  final InventoryItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}
