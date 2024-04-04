import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/order_confirmation.dart';

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
            'details': Seller.fromFirestore(sellerDoc),
            'items': <CartItem>[]
          };
        }
        itemsBySeller[sellerId]['items'].add(cartItem);
      }
      return itemsBySeller;
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

                return ListTile(
                  title: Text(seller.stallName), // Display seller name
                  subtitle: Text(seller.stallLocation), // Display seller location
                  onTap: () {
                    // Navigate to OrderConfirmationPage with all items from the same stall
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderConfirmationPage(
                          seller: seller,
                          cartItems: items,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      // Navigate to OrderConfirmationPage with all items from the same stall
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrderConfirmationPage(
                            seller: seller,
                            cartItems: items,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}