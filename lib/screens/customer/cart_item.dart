import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          var cartItem = cart.items[index];
          return ListTile(
            title: Text(cartItem.item.itemName),
            subtitle: Text('Quantity: ${cartItem.quantity}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                cart.removeCartItem(cartItem);
              },
            ),
          );
        },
      ),
    );
  }
}
