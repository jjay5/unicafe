import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final String? id;
  final String sellerID;
  final String? itemPhoto; //Make itemPhoto nullable
  final String itemName;
  final String itemCategory;
  final double price;
  final String durationToCook;
  final bool availability;

  MenuItem({
    this.id,
    required this.sellerID,
    this.itemPhoto,
    required this.itemName,
    required this.itemCategory,
    required this.price,
    required this.durationToCook,
    this.availability = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerID': sellerID,
      'itemPhoto': itemPhoto,
      'itemName': itemName,
      'itemCategory': itemCategory,
      'price': price,
      'durationToCook' : durationToCook,
      'availability' : availability
    };
  }

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      sellerID: data['sellerID'] ?? '',
      itemPhoto: data['itemPhoto'] ?? '',
      itemName: data['itemName'] ?? '',
      itemCategory: data['itemCategory'] ?? '',
      price: (data['price'] ?? 0).toDouble(), // Convert to double
      durationToCook: data['durationToCook'] ?? '',
      availability: data['availability'] ?? true,
    );
  }

  static MenuItem fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] ?? '',
      sellerID: map['sellerID'] ?? '',
      itemPhoto: map['itemPhoto'] ?? '',
      itemName: map['itemName'] ?? '',
      itemCategory: map['itemCategory'] ?? '',
      price: (map['price'] ?? 0).toDouble(), // Convert to double
      durationToCook: map['durationToCook'] ?? '',
      availability: map['availability'] ?? true,
    );
  }
}

class MenuProvider extends ChangeNotifier {

  List<MenuItem> _menuItems = [];

  List<MenuItem> get menuItems => _menuItems;

  // Constructor to load items once this provider is called
  MenuProvider() {
    loadMenuItems();
  }

  // Adds or updates a menu item in the provider
  void addOrUpdateMenuItem(MenuItem menuItem) {
    int index = _menuItems.indexWhere((item) => item.id == menuItem.id);
    if (index != -1) {
      // Update
      _menuItems[index] = menuItem;
    } else {
      // Add
      _menuItems.add(menuItem);
    }
    notifyListeners();
  }

  // Updates the availability of a specific menu item
  void setMenuItemAvailability(String menuItemId, bool isAvailable) {
    int index = _menuItems.indexWhere((item) => item.id == menuItemId);
    if (index != -1) {
      _menuItems[index] = MenuItem(
        id: _menuItems[index].id,
        sellerID: _menuItems[index].sellerID,
        itemPhoto: _menuItems[index].itemPhoto,
        itemName: _menuItems[index].itemName,
        itemCategory: _menuItems[index].itemCategory,
        price: _menuItems[index].price,
        durationToCook: _menuItems[index].durationToCook,
        availability: isAvailable,
      );
      notifyListeners();
    }
  }

  Future<void> loadMenuItems() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('menuItems')
        .where('availability', isEqualTo: true)
        .get();

    _menuItems = snapshot.docs
        .map((doc) => MenuItem.fromFirestore(doc))
        .toList();
    notifyListeners();
  }
}


