import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/models/seller.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Seller seller;
  final List<CartItem> cartItems;

  const OrderConfirmationPage({
    Key? key,
    required this.seller,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  late List<CartItem> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Your Order'),
      ),
      body: Column(
        children: [
          Text('Ordering from: ${widget.seller.stallName}'),
          Text('Location: ${widget.seller.stallLocation}'),
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                CartItem item = _cartItems[index];
                return ListTile(
                  title: Text(item.item.itemName),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      _removeItem(index);
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmOrder(context),
            child: Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    // Update the cart provider to remove the item
    Provider.of<CartProvider>(context, listen: false).removeCartItem(index);
  }

  void _confirmOrder(BuildContext context) {
    // Here you can handle the order confirmation logic, such as sending order details to the seller
  }
}
