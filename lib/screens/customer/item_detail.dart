import 'package:flutter/material.dart';
import 'package:unicafe/models/menu_item.dart';

class ItemDetailsPage extends StatefulWidget {
  final MenuItem menuItem;

  const ItemDetailsPage({Key? key, required this.menuItem}) : super(key: key);

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final TextEditingController _noteController = TextEditingController();
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem.itemName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.menuItem.itemPhoto != null)
              Image.network(widget.menuItem.itemPhoto!),
            ListTile(
              title: Text(widget.menuItem.itemName),
              subtitle: Text('\$${widget.menuItem.price.toStringAsFixed(2)}'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text('Quantity:'),
                  IconButton(
                    icon: Icon(Icons.remove),
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
                    icon: Icon(Icons.add),
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
                decoration: InputDecoration(
                  labelText: 'Note to chef (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Here you can handle the action when the user wants to add the item to their cart
                  // You might want to use a provider or another state management solution to manage the cart state
                  print('Item added to cart with quantity: $_quantity and note: ${_noteController.text}');
                },
                child: Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
