import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';

class UpdateMenuItemPage extends StatefulWidget {
  final MenuItem menuItem;

  const UpdateMenuItemPage({super.key, required this.menuItem});

  @override
  UpdateMenuItemPageState createState() => UpdateMenuItemPageState();
}

class UpdateMenuItemPageState extends State<UpdateMenuItemPage> {
  late TextEditingController _itemNameController;
  late TextEditingController _itemCategoryController;
  late TextEditingController _priceController;
  late TextEditingController _durationToCookController;

  String? _selectedCategory;
  List<String> _categories = [];
  // Predefined category list
  List<String> predefinedCategories = ['Breakfast', 'Lunch & Dinner', 'Soup', 'Snacks', 'Desserts', 'Beverages', 'Special Deals'];

  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Failed to pick image: $e');
      }
    }
  }

  Future<String?> uploadFile(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = "menuItems/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
    try {
      await storage.ref(fileName).putFile(image);
      return await storage.ref(fileName).getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  void fetchCategories() async {
    User? user = FirebaseAuth.instance.currentUser;

    var snapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(user?.uid)
        .collection('categories')
        .get();

    var fetchedCategories = snapshot.docs.map((doc) => doc.id).toList();
    setState(() {
      _categories = fetchedCategories;
      // Ensure the current selected category is valid or reset it
      /*if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.isNotEmpty ? _categories[0] : null;
      }*/
    });
  }

  void loadCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid)
          .collection('categories')
          .get();
      if (mounted) {
        setState(() {
          _categories = querySnapshot.docs.map((doc) => doc.id).toList();
        });
      }
    }
  }

  Future<void> addCustomCategory(String newCategory) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(user.uid)
          .collection('categories')
          .doc(newCategory)
          .set({});
      loadCategories(); // Reload categories after adding a new one
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _itemNameController = TextEditingController(text: widget.menuItem.itemName);
    _itemCategoryController = TextEditingController(text: widget.menuItem.itemCategory);
    _priceController = TextEditingController(text: widget.menuItem.price.toString());
    _durationToCookController = TextEditingController(text: widget.menuItem.durationToCook);
    //_selectedCategory =  widget.menuItem.itemCategory;
    //_selectedCategory = _categories.contains(widget.menuItem.itemCategory) ? widget.menuItem.itemCategory : 'Null';

    _selectedCategory = _categories.contains(widget.menuItem.itemCategory) || predefinedCategories.contains(widget.menuItem.itemCategory)
        ? widget.menuItem.itemCategory
        : 'Custom';
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
              _buildImageDisplay(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: getImage,
                child: const Text('Change Photo'),
              ),
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  DropdownButtonFormField<String>(
                    key: UniqueKey(),
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        if (newValue == 'Custom') {
                          // This is only needed if user selects "Custom"
                          _itemCategoryController.clear();
                        }
                      });
                    },
                    items: [...predefinedCategories, ..._categories, 'Custom'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(value),
                            if (!predefinedCategories.contains(value) && value != 'Custom') // Add delete icon for custom categories only
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text('Are you sure you want to delete this category?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false); // Dismiss dialog and return false
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true); // Dismiss dialog and return true
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmDelete) {
                                    User? user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('sellers')
                                            .doc(user.uid)
                                            .collection('categories')
                                            .doc(value)
                                            .delete();

                                        setState(() {
                                          _categories.remove(value);
                                          _selectedCategory = null; // Clear selected category to force refresh
                                        });
                                      } catch (e) {
                                        if (kDebugMode) {
                                          print('Error deleting category: $e');
                                        }
                                        // Handle error, show message to the user
                                      }
                                    }
                                  }
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Item Category',
                    ),
                  ),

                  if (_selectedCategory == 'Custom') ...[
                    TextField(
                      controller: _itemCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Custom Category',
                      ),
                    ),
                  ],
                ],
              ),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: 'RM ', // Add prefix text
                ),
              ),
              TextField(
                controller: _durationToCookController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Duration to Cook',
                  suffixText: ' Minutes',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedCategory == 'Custom' && _itemCategoryController.text.trim().isNotEmpty) {
                    await addCustomCategory(_itemCategoryController.text.trim());
                    _selectedCategory = _itemCategoryController.text.trim();
                  }

                  String? itemPhotoUrl;
                  if (_image != null) {
                    itemPhotoUrl = await uploadFile(_image!);
                  }
                  MenuItem updatedMenuItem = MenuItem(
                    id: widget.menuItem.id,
                    sellerID: widget.menuItem.sellerID,
                    itemPhoto: itemPhotoUrl ?? widget.menuItem.itemPhoto,
                    itemName: _itemNameController.text.trim(),
                    itemCategory: _selectedCategory!,
                    price: double.parse(_priceController.text),
                    durationToCook: _durationToCookController.text.trim(),
                    availability: widget.menuItem.availability,
                  );

                  await FirebaseFirestore.instance.collection('menuItems').doc(widget.menuItem.id).update(updatedMenuItem.toMap());

                  if (!context.mounted) return;
                  Provider.of<MenuProvider>(context, listen: false).addOrUpdateMenuItem(updatedMenuItem);

                  // Show a SnackBar to notify the user
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item updated successfully '),
                      duration: Duration(seconds: 2), // Adjust duration as needed
                    ),
                  );

                  // Navigate back to the previous page
                  Navigator.pop(context);
                },
                child: const Text('Update Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_image != null) {
      // Display the newly picked image
      return Image.file(
        _image!,
        width: 200, // Specify the desired width
        height: 200, // Specify the desired height
        fit: BoxFit.contain, // Adjusts the image to fit the specified dimensions
      );
    }
    else if (widget.menuItem.itemPhoto != null && widget.menuItem.itemPhoto!.isNotEmpty) {
      // Display existing network image if available
      return Image.network(widget.menuItem.itemPhoto!,
        width: 200, // Specify the desired width
        height: 200, // Specify the desired height
        fit: BoxFit.contain, // Adjusts the image to fit the specified dimensions
      ); // Using ! to assert non-nullability
    } else {
      // Display a placeholder if no image is available
      return Image.asset('assets/images/default_image.png'); // Ensure you have a placeholder asset
    }
  }
}