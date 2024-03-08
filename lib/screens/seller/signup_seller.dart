import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/seller.dart';

class SignUpSellerPage extends StatelessWidget {
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _stallLocationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignUpSellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _stallNameController,
              decoration: const InputDecoration(labelText: 'Stall Name'),
            ),
            TextField(
              controller: _stallLocationController,
              decoration: const InputDecoration(labelText: 'Stall Location'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: () async {
                UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                // Create a Customer instance
                Seller newSeller = Seller(
                  id: userCredential.user!.uid, // Firestore generates the UID
                  stallName: _stallNameController.text.trim(),
                  stallLocation: _stallLocationController.text.trim(),
                  phone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                );

                // Add the Seller details in Firestore
                await _firestore.collection('seller').doc(userCredential.user!.uid).set(newSeller.toMap());
              },
            ),
          ],
        ),
      ),
    );
  }
}
