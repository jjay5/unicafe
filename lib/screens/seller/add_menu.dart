import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMenuItemPage extends StatefulWidget {
  const AddMenuItemPage({super.key});

  @override
  AddMenuItemPageState createState() => AddMenuItemPageState();
}

class AddMenuItemPageState extends State<AddMenuItemPage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCategoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationToCookController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  String? _selectedCategory;
  List<String> _categories = [];
  // Predefined category list
  List<String> predefinedCategories = ['Breakfast', 'Lunch & Dinner', 'Soup', 'Snacks', 'Desserts', 'Beverages', 'Special Deals'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key for the form

  @override
  void initState() {
    super.initState();
    loadCategories();
    _itemNameController.addListener(_updateValidation);
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

  @override
  void dispose() {
    _itemNameController.removeListener(_updateValidation);
    _priceController.removeListener(_updateValidation);
    _durationToCookController.removeListener(_updateValidation);
    //_passwordController.removeListener(_updateValidation);
    //_reEnterPasswordController.removeListener(_updateValidation);

    _itemNameController.dispose();
    _priceController.dispose();
    _durationToCookController.dispose();
    //_passwordController.dispose();
    //_reEnterPasswordController.dispose();

    super.dispose();
  }

  void _updateValidation() {
    setState(() {}); // Update UI when fill the form
  }

  String? _validateItemName(String? value) {
    if (value!.isEmpty) {
      return 'Please enter the item name';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value!.isEmpty) {
      return 'Please enter the item price';
    }
    return null;
  }

  String? _validateDuration(String? value) {
    if (value!.isEmpty) {
      return 'Please enter the duration time to cook the item';
    }
    return null;
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

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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

  @override
  Widget build(BuildContext context) {
    final seller = Provider.of<SellerProvider>(context).seller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Item Photo'),
                if (_image != null)
                  Align(
                    child: Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: getImage,
                  child: Text(_image == null ? 'Add Photo' : 'Change Photo'),
                ),
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                    suffixIcon: _itemNameController.text.isEmpty
                        ? const Icon(Icons.error, color: Colors.red)  // Error icon if empty
                        : const Icon(Icons.check, color: Colors.green),  // Check icon if not empty
                  ),
                  validator: _validateItemName,
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
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: 'RM ', // Add prefix text
                    hintText: 'Enter Item Price',
                    suffixIcon: _priceController.text.isEmpty
                        ?  const Icon(Icons.error, color: Colors.red)  // Error icon if empty
                        :  const Icon(Icons.check, color: Colors.green),  // Check icon if not empty
                  ),
                  validator: _validatePrice,
                ),
                TextFormField(
                  controller: _durationToCookController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Duration to Cook',
                    suffixText: ' Minutes',
                    suffixIcon: _durationToCookController.text.isEmpty
                      ?  const Icon(Icons.error, color: Colors.red)  // Error icon if empty
                      :  const Icon(Icons.check, color: Colors.green),  // Check icon if not empty
                  ),
                  validator: _validateDuration,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: seller == null ? null : () async {

                    final itemName = _itemNameController.text.trim();
                    final price = _priceController.text.trim();
                    final duration = _durationToCookController.text.trim();
                    final category = _selectedCategory ?? '';

                    if (itemName.isEmpty || price.isEmpty || duration.isEmpty || category.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all the required fields.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    try {
                      var newCategory = _itemCategoryController.text.trim();
                      if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
                        addCustomCategory(newCategory);
                        _selectedCategory = newCategory;// Add the custom category
                      }

                      String? itemPhotoUrl;

                      if (_image != null) {
                        itemPhotoUrl = await uploadFile(_image!);
                      }

                      MenuItem newMenuItem = MenuItem(
                        id: null,
                        sellerID: seller.id, // Use the seller ID from the provider
                        itemPhoto: itemPhotoUrl ?? '',
                        itemName: _itemNameController.text.trim(),
                        //itemCategory: _itemCategoryController.text.trim(),
                        itemCategory: _selectedCategory ?? '',
                        price: double.parse(_priceController.text),
                        durationToCook: _durationToCookController.text.trim(),
                        availability: true,
                        isDeleted: false,
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
                          isDeleted: newMenuItem.isDeleted,
                        );
                        Provider.of<MenuProvider>(context, listen: false).addOrUpdateMenuItem(newMenuItem);
                      });

                      // Show a SnackBar to notify the user
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item added successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Navigate back to the previous page
                      Navigator.pop(context);
                    } catch (e) {
                      // Handle any other errors
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Add menu item failed: ${e.toString()}'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}