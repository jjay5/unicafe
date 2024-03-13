import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';

class AddMenuItemPage extends StatefulWidget {
  @override
  _AddMenuItemPageState createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCategoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationToCookController = TextEditingController();
  File? _image; // To store the picked image file
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> uploadFile(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = "menuItems/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
    try {
      await storage.ref(fileName).putFile(image);
      return await storage.ref(fileName).getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = Provider.of<SellerProvider>(context).seller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Added to ensure the form is scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_image != null)
                Image.file(_image!),
              ElevatedButton(
                onPressed: getImage,
                child: Text('Select Image'),
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: _durationToCookController,
                decoration: const InputDecoration(labelText: 'Duration to Cook'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: seller == null ? null : () async {
                  String? itemPhotoUrl;
                  if (_image != null) {
                    itemPhotoUrl = await uploadFile(_image!);
                  }
                  MenuItem newMenuItem = MenuItem(
                    id: null,
                    sellerID: seller.id, // Use the seller ID from the provider
                    itemPhoto: itemPhotoUrl ?? '',
                    itemName: _itemNameController.text.trim(),
                    itemCategory: _itemCategoryController.text.trim(),
                    price: double.parse(_priceController.text),
                    durationToCook: _durationToCookController.text.trim(),
                    availability: true,
                  );

                  await FirebaseFirestore.instance.collection('menuItems').add(newMenuItem.toMap()).then((docRef) {
                    newMenuItem = MenuItem(
                      id: docRef.id,
                      sellerID: newMenuItem.sellerID,
                      itemPhoto: newMenuItem.itemPhoto,
                      itemName: newMenuItem.itemName,
                      itemCategory: newMenuItem.itemCategory,
                      price: newMenuItem.price,
                      durationToCook: newMenuItem.durationToCook,
                      availability: newMenuItem.availability,
                    );
                    Provider.of<MenuProvider>(context, listen: false).addOrUpdateMenuItem(newMenuItem);
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuManagementPage()),
                  );
                },
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}