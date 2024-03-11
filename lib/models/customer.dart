import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'customer',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
    );
  }

  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
    );
  }
}

class CustomerProvider extends ChangeNotifier {
  Customer? _customer;

  Customer? get customer => _customer;

  void setCustomer(Customer customer) {
    _customer = customer;
    notifyListeners();
  }
}