import 'package:flutter/material.dart';
import 'package:unicafe/models/menu_item.dart';

class CartItem {
  final MenuItem item;
  final int quantity;
  final String note;
  final double totalItemPrice;

  CartItem({
    required this.item,
    required this.quantity,
    String? note,
    required this.totalItemPrice,
  }) : note = note ?? '-'; // Use "None" if note is null
}

class CartProvider with ChangeNotifier {

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addToCart(MenuItem item, int quantity, String? note) {
    // Normalize note by considering null or empty notes as 'None'
    final normalizedNote = note?.isEmpty ?? true ? '-' : note;

    // Find index based on item ID and note
    // For items without notes ('None'), this finds any matching item
    // For items with notes, this looks for an exact match
    int index = _items.indexWhere((cartItem) =>
    cartItem.item.id == item.id &&
        (normalizedNote == '-' ? cartItem.note == '-' : cartItem.note == normalizedNote));

    if (index != -1) {
      // If item exists in the cart, update its quantity
      var existingItem = _items[index];
      var updatedQuantity = existingItem.quantity + quantity;
      var updatedTotalPrice = updatedQuantity * item.price; // Calculate the total price based on the updated quantity

      _items[index] = CartItem(
        item: existingItem.item,
        quantity: updatedQuantity,
        note: existingItem.note,
        totalItemPrice: updatedTotalPrice, // Update the total price
      );
    } else {
      // If item does not exist, add it as a new entry
      var totalItemPrice = quantity * item.price; // Calculate total price for new item
      _items.add(CartItem(
        item: item,
        quantity: quantity,
        note: normalizedNote,
        totalItemPrice: totalItemPrice, // Assign the calculated total price
      ));
    }

    notifyListeners();
  }

  void removeCartItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}




