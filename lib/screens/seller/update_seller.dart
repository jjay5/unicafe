import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/seller.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/screens/login.dart';

class UpdateSellerPage extends StatefulWidget {
  const UpdateSellerPage({super.key});

  @override
  UpdateSellerPageState createState() => UpdateSellerPageState();
}

class UpdateSellerPageState extends State<UpdateSellerPage> {
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  final List<String> _stallLocations = ['Student Pavillion', 'Bunga Raya Cafe', 'Alamanda Cafe', 'Cempaka Cafe', 'TAZ Cafe',
    'Seroja Cafe', 'Kenanga Cafe', 'Dahlia Cafe', 'Rafflesia Cafe', 'Lakeview Cafe'];
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  /*_loadCurrentUser() async {
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
  }*/
  _loadCurrentUser() async {
    setState(() => _isLoading = true);
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      var sellerSnapshot = await _firestore.collection('sellers').doc(currentUser.uid).get();
      if (sellerSnapshot.exists) {
        Seller currentSeller = Seller.fromFirestore(sellerSnapshot);
        _stallNameController.text = currentSeller.stallName;
        //_stallLocationController.text = currentSeller.stallLocation;
        _selectedLocation = currentSeller.stallLocation;
        _phoneController.text = currentSeller.phone;
        _emailController.text = currentSeller.email;
        if (!mounted) return;
        Provider.of<SellerProvider>(context, listen: false).setSeller(currentSeller);
      }
    }
    setState(() => _isLoading = false);
  }

  _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: <Widget>[
          TextButton.icon(
            label: const Text('Logout', style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
            icon: const Icon(Icons.logout, color: Colors.blueGrey),
            onPressed: _logout,
          ),
        ],
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
            /*
            TextField(
              controller: _stallLocationController,
              decoration: const InputDecoration(labelText: 'Stall Location'),
            ),*/
            Column(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: 'Stall Location',
                  ),
                  value: _selectedLocation,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLocation = newValue;
                    });
                  },
                  items: _stallLocations.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Please select a location' : null,
                ),
              ],
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+60 ',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false,
            ),
            const SizedBox(height: 20),
            /*ElevatedButton(
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
            ),*/
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                setState(() => _isLoading = true);

                // Construct a new Seller object with updated data
                Seller updatedSeller = Seller(
                  id: _auth.currentUser!.uid,
                  stallName: _stallNameController.text.trim(),

                  //stallLocation: _stallLocationController.text.trim(),
                  stallLocation: _selectedLocation ?? '',
                  phone: _phoneController.text.trim(),
                  email: _emailController.text, // unchanged
                );

                // Update Firestore with the new data
                await _firestore.collection('sellers').doc(_auth.currentUser!.uid).update(updatedSeller.toMap());

                // Update the provider with new seller data
                if (!context.mounted) return;
                Provider.of<SellerProvider>(context, listen: false).setSeller(updatedSeller);

                setState(() => _isLoading = false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
