import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unicafe/models/seller.dart'; // Import your Seller model
import 'package:unicafe/models/customer.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('customers').doc(userId).get();
      if (userDoc.exists) {
        return 'customer';
      }
      userDoc = await _firestore.collection('sellers').doc(userId).get();
      if (userDoc.exists) {
        return 'seller';
      }
      return 'unknown role'; // Unknown role
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user role: $e');
      }
      return ''; // Return empty string if an error occurs
    }
  }

  Future<Customer?> fetchCustomerDetails(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('customers').doc(userId).get();
      if (snapshot.exists) {
        return Customer.fromFirestore(snapshot);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer details: $e');
      }
    }
    return null;
  }

  Future<Seller?> fetchSellerDetails(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('sellers').doc(userId).get();
      if (snapshot.exists) {
        return Seller.fromFirestore(snapshot);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching seller details: $e');
      }
    }
    return null;
  }
}
