import 'package:cloud_firestore/cloud_firestore.dart';

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
      id: map['id'] ?? '', // Assuming 'id' might be part of the map, provide a fallback if it's not.
      name: map['name'] ?? '', // Provide a fallback to ensure the constructor receives a non-null value.
      phone: map['phone'] ?? '', // Provide a fallback to ensure the constructor receives a non-null value.
      email: map['email'] ?? '', // Provide a fallback to ensure the constructor receives a non-null value.
      role: map['role'] ?? 'customer', // Provide a default role if not specified in the map.
    );
  }
}
