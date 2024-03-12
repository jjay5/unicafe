import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';

class AddMenuItemPage extends StatelessWidget {
  final TextEditingController _itemPhotoController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCategoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationToCookController = TextEditingController();

//  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddMenuItemPage({super.key});

  @override
  Widget build(BuildContext context) {

    //Access Seller provider
    final seller = Provider.of<SellerProvider>(context).seller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _itemPhotoController,
              decoration: const InputDecoration(labelText: 'Item Photo'),
            ),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _itemCategoryController,
              decoration: const InputDecoration(labelText: 'Item Category'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _durationToCookController,
              decoration: const InputDecoration(labelText: 'DurationToCook'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: seller == null ? null : () async {

                // Create a Customer instance
                MenuItem newMenuItem = MenuItem(
                  id: null,
                  sellerID: seller.id, // Use the seller ID from the provider
                  itemPhoto: _itemPhotoController.text.trim(),
                  itemName: _itemNameController.text.trim(),
                  itemCategory: _itemCategoryController.text.trim(),
                  price: double.parse(_priceController.text),
                  durationToCook: _durationToCookController.text.trim(),
                  availability: true,
                );

                // Add the MenuItem details in Firestore
                //await _firestore.collection('menuItems').add(newMenuItem.toMap());
                await _firestore.collection('menuItems').add(newMenuItem.toMap()).then((docRef) {
                  // Recreating the MenuItem instance with Firestore generated ID
                  newMenuItem = MenuItem(
                    id: docRef.id, // Firestore generated ID
                    sellerID: newMenuItem.sellerID,
                    itemPhoto: newMenuItem.itemPhoto,
                    itemName: newMenuItem.itemName,
                    itemCategory: newMenuItem.itemCategory,
                    price: newMenuItem.price,
                    durationToCook: newMenuItem.durationToCook,
                    availability: newMenuItem.availability,
                  );

                  // update MenuProvider to maintain a local cache/list
                  Provider.of<MenuProvider>(context, listen: false).addOrUpdateMenuItem(newMenuItem);
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuManagementPage()), // Ensure this matches your login page class name
                );
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
