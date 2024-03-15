import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/seller.dart';

class UpdateSellerPage extends StatefulWidget {
  const UpdateSellerPage({super.key});

  @override
  UpdateSellerPageState createState() => UpdateSellerPageState();
}

class UpdateSellerPageState extends State<UpdateSellerPage> {
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _stallLocationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  _loadCurrentUser() async {
    setState(() => _isLoading = true);
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      var customerSnapshot = await _firestore.collection('sellers').doc(currentUser.uid).get();
      Seller currentSeller = Seller.fromMap(customerSnapshot.data()!);
      _stallNameController.text = currentSeller.stallName;
      _stallLocationController.text = currentSeller.stallLocation;
      _phoneController.text = currentSeller.phone;
      _emailController.text = currentSeller.email;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Seller Account'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
              enabled: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                setState(() => _isLoading = true);

                // convert object to Map
                await _firestore.collection('sellers').doc(_auth.currentUser!.uid).update({
                  'stallName': _stallNameController.text.trim(),
                  'stallLocation': _stallLocationController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  // Email is not updated as it's assumed to be unchanged
                });
                setState(() => _isLoading = false);

              },
            ),
          ],
        ),
      ),
    );
  }
}
