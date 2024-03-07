import 'package:cloud_firestore/cloud_firestore.dart';

class Seller {
  final String id;
  final String stall_name;
  final String stall_location;
  final String phone;
  final String email;
  final String role;

  Seller({
    required this.id,
    required this.stall_name,
    required this.stall_location,
    required this.phone,
    required this.email,
    this.role = 'seller',
  });

  Map<String, dynamic> toMap() {
    return {
      'stall_name': stall_name,
      'stall location': stall_location,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  factory Seller.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Seller(
      id: doc.id,
      stall_name: data['stall_name'] ?? '',
      stall_location: data['stall_location' ?? ''],
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'seller',
    );
  }
}
