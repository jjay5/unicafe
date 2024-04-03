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
    _items.add(CartItem(item: item, quantity: quantity, note: note));
    notifyListeners();
  }

  void removeCartItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }
}