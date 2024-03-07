import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/customer.dart';

class UpdateCustomerPage extends StatefulWidget {
  @override
  _UpdateCustomerPageState createState() => _UpdateCustomerPageState();
}

class _UpdateCustomerPageState extends State<UpdateCustomerPage> {
  final TextEditingController _nameController = TextEditingController();
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
      var customerSnapshot = await _firestore.collection('customer').doc(currentUser.uid).get();
      Customer currentCustomer = Customer.fromMap(customerSnapshot.data()!);
      _nameController.text = currentCustomer.name;
      _phoneController.text = currentCustomer.phone;
      _emailController.text = currentCustomer.email;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Customer Account'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            // Email is displayed for information only, assuming it cannot be changed here
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false, // Make the email field read-only
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                setState(() => _isLoading = true);
                // Assuming you have a method in Customer model to convert object to Map
                await _firestore.collection('customer').doc(_auth.currentUser!.uid).update({
                  'name': _nameController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  // Email is not updated as it's assumed to be unchanged
                });
                setState(() => _isLoading = false);
                Navigator.of(context).pop(); // Optionally pop back to previous screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
