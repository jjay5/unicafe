import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/screens/seller/add_menu.dart';
import 'package:unicafe/screens/seller/homepage_seller.dart';
import 'package:unicafe/screens/customer/homepage_customer.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';
import 'package:unicafe/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
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

      final UserService userService = UserService();

      // Retrieve user role from Firestore
      String role = await userService.getUserRole(userCredential.user!.uid);

      if (role == 'customer') {
        Customer? customer = await userService.fetchCustomerDetails(userCredential.user!.uid);
        if (customer != null) {
          // Set customer provider
          Provider.of<CustomerProvider>(context, listen: false).setCustomer(customer);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomePage()));
        } else {
          // Handle customer not found
          if (kDebugMode) {
            print('Customer details not found');
          }
        }
      } else if (role == 'seller') {
        Seller? seller = await userService.fetchSellerDetails(userCredential.user!.uid);
        if (seller != null) {
          // Set seller provider
          Provider.of<SellerProvider>(context, listen: false).setSeller(seller);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  const SellerHomePage()));
        } else {
          // Handle seller not found
          if (kDebugMode) {
            print('Seller details not found');
          }
        }
      } else {
        // Handle unknown role
        if (kDebugMode) {
          print('Unknown role');
        }
      }
    } catch (e) {
      // Handle login errors
      if (kDebugMode) {
        print('Login Error: $e');
      }
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to login. Please check your credentials.'),
      ));
    }
  }
}