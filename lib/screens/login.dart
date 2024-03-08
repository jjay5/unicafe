import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/screens/seller/update_seller.dart';
import 'package:unicafe/screens/customer/update_customer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Retrieve user role from Firestore
      String role = await _getUserRole(userCredential.user!.uid);

      // Navigate based on role
      if (role == 'customer') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpdateCustomerPage()));
      } else if (role == 'seller') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UpdateSellerPage()));
      } else {
        // Handle unknown role
      }
    } catch (e) {
      // Handle login errors
      print('Login Error: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to login. Please check your credentials.'),
      ));
    }
  }

  Future<String> _getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('customer').doc(userId).get();
      if (userDoc.exists) {
        return 'customer';
      }

      userDoc = await _firestore.collection('seller').doc(userId).get();
      if (userDoc.exists) {
        return 'seller';
      }

      return ''; // Unknown role
    } catch (e) {
      print('Error fetching user role: $e');
      return ''; // Return empty string if an error occurs
    }
  }
}