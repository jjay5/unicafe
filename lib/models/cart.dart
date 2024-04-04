import 'package:flutter/material.dart';
import 'package:unicafe/models/menu_item.dart';

class CartItem {
  final MenuItem item;
  final int quantity;
  final String note;

  CartItem({required this.item, required this.quantity, required this.note});
}

class CartProvider with ChangeNotifier {

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addToCart(MenuItem item, int quantity, String note) {
    // Check if the item is already in the cart
    int index = _items.indexWhere((cartItem) => cartItem.item.id == item.id);

    if (index != -1) {
      // If the item exists, update its quantity
      _items[index] = CartItem(
        item: _items[index].item,
        quantity: _items[index].quantity + quantity, // Add the new quantity to the existing quantity
        note: _items[index].note,
      );
    } else {
      // If the item doesn't exist, add it to the cart
      _items.add(CartItem(item: item, quantity: quantity, note: note));
    }
    notifyListeners();
  }

  void removeCartItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.quantity * item.item.price));
  }

}




