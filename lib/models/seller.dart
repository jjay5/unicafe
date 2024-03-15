import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Seller {
  final String id;
  final String stallName;
  final String stallLocation;
  final String phone;
  final String email;
  final String role;

  Seller({
    required this.id,
    required this.stallName,
    required this.stallLocation,
    required this.phone,
    required this.email,
    this.role = 'seller',
  });

  Map<String, dynamic> toMap() {
    return {
      'stallName': stallName,
      'stallLocation': stallLocation,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  factory Seller.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Seller(
      id: doc.id,
      stallName: data['stallName'] ?? '',
      stallLocation: data['stallLocation'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'seller',
    );
  }

  static Seller fromMap(Map<String, dynamic> map) {
    return Seller(
      id: map['id'] ?? '',
      stallName: map['stallName'] ?? '',
      stallLocation: map['stallLocation'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'seller',
    );
  }
}

class SellerProvider extends ChangeNotifier {
  Seller? _seller;

  Seller? get seller => _seller;

  void setSeller(Seller seller) {
    _seller = seller;
    notifyListeners();
  }


}

