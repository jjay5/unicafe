import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/cart.dart';

class ItemDetailsPage extends StatefulWidget {
  final MenuItem menuItem;

  const ItemDetailsPage({super.key, required this.menuItem});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final TextEditingController _noteController = TextEditingController();
  int _quantity = 1;
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem.itemName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageDisplay(),
            ListTile(
              title: Text(widget.menuItem.itemName),
              subtitle: Text('RM${widget.menuItem.price.toStringAsFixed(2)}'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Quantity:'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 1) {
                          _quantity--;
                        }
                      });
                    },
                  ),
                  Text('$_quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note to chef (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (kDebugMode) {
                    print('Item added to cart with quantity: $_quantity and note: ${_noteController.text}');
                  }
                  // Add item to cart using Provider
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(widget.menuItem, _quantity, _noteController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Added to cart'),
                  ));
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_image != null) {
      // Display the newly picked image
      return Image.file(
        _image!,
        width: 300, // Specify the desired width
        height: 300, // Specify the desired height
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