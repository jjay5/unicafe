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
    var sellerProvider = Provider.of<SellerProvider>(context, listen: false);

    Future<Map<String, List<CartItem>>> groupItemsBySeller() async {
      Map<String, List<CartItem>> itemsBySeller = {};

      for (var cartItem in cart.items) {
        var sellerDoc = await FirebaseFirestore.instance.collection('sellers').doc(cartItem.item.sellerID).get();
        var seller = Seller.fromFirestore(sellerDoc);

        if (!itemsBySeller.containsKey(seller.stallName)) {
          itemsBySeller[seller.stallName] = [];
        }
        itemsBySeller[seller.stallName]!.add(cartItem);
      }

      return itemsBySeller;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder<Map<String, List<CartItem>>>(
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
                String sellerName = itemsBySeller.keys.elementAt(index);
                List<CartItem> items = itemsBySeller[sellerName]!;
                return ExpansionTile(
                  title: Text(sellerName),
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
