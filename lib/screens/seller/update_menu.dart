import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';

class UpdateMenuItemPage extends StatefulWidget {
  final MenuItem menuItem;

  UpdateMenuItemPage({required this.menuItem});

  @override
  _UpdateMenuItemPageState createState() => _UpdateMenuItemPageState();
}

class _UpdateMenuItemPageState extends State<UpdateMenuItemPage> {
  late TextEditingController _itemNameController;
  late TextEditingController _itemCategoryController;
  late TextEditingController _priceController;
  late TextEditingController _durationToCookController;
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
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
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.menuItem.itemName);
    _itemCategoryController = TextEditingController(text: widget.menuItem.itemCategory);
    _priceController = TextEditingController(text: widget.menuItem.price.toString());
    _durationToCookController = TextEditingController(text: widget.menuItem.durationToCook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Item Photo'),
              if (_image != null)
                Image.file(_image!),
              ElevatedButton(
                onPressed: getImage,
                child: const Text('Change Photo'),
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
                onPressed: () async {
                  String? itemPhotoUrl;
                  if (_image != null) {
                    itemPhotoUrl = await uploadFile(_image!);
                  }
                  MenuItem updatedMenuItem = MenuItem(
                    id: widget.menuItem.id,
                    sellerID: widget.menuItem.sellerID,
                    itemPhoto: itemPhotoUrl ?? widget.menuItem.itemPhoto,
                    itemName: _itemNameController.text.trim(),
                    itemCategory: _itemCategoryController.text.trim(),
                    price: double.parse(_priceController.text),
                    durationToCook: _durationToCookController.text.trim(),
                    availability: widget.menuItem.availability,
                  );

                  await FirebaseFirestore.instance.collection('menuItems').doc(widget.menuItem.id).update(updatedMenuItem.toMap());
                  Provider.of<MenuProvider>(context, listen: false).addOrUpdateMenuItem(updatedMenuItem);
                  Navigator.pop(context); // Navigate back to the previous screen
                },
                child: const Text('Update Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
