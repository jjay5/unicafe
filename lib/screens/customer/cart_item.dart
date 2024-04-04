import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/models/seller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    Future<Map<String, dynamic>> groupItemsBySeller() async {
      Map<String, dynamic> itemsBySeller = {};

      for (var cartItem in cart.items) {
        String sellerId = cartItem.item.sellerID;
        DocumentSnapshot sellerDoc = await FirebaseFirestore.instance.collection('sellers').doc(sellerId).get();

        if (!itemsBySeller.containsKey(sellerId)) {
          itemsBySeller[sellerId] = {
            'details': Seller.fromFirestore(sellerDoc), // Assuming you have a method like this
            'items': <CartItem>[]
          };
        }
        itemsBySeller[sellerId]['items'].add(cartItem);
      }

      return itemsBySeller;
    }

    // Function to navigate to order confirmation page
    void navigateToOrderConfirmationPage(String sellerID) {
      // Navigate to order confirmation page
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: groupItemsBySeller(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          } else {
            var itemsBySeller = snapshot.data!;
            return ListView.builder(
              itemCount: itemsBySeller.keys.length,
              itemBuilder: (context, index) {
                String sellerId = itemsBySeller.keys.elementAt(index);
                Seller seller = itemsBySeller[sellerId]['details'];
                List<CartItem> items = itemsBySeller[sellerId]['items'];
                return ExpansionTile(
                  title: Text(seller.stallName), // Display seller name
                  subtitle: Text(seller.stallLocation), // Display seller location
                  children: items.map((cartItem) => ListTile(
                    title: Text(cartItem.item.itemName),
                    subtitle: Text('Quantity: ${cartItem.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        cart.removeCartItem(cartItem);
                      },
                    ),
                  )).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
