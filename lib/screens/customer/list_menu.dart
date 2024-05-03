import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/item_detail.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/screens/customer/ratings_reviews.dart';
import 'package:unicafe/screens/customer/order_confirmation.dart';

class MenuPage extends StatelessWidget {
  final String sellerId;

  const MenuPage({super.key, required this.sellerId});

  Future<List<MenuItem>> fetchMenuItems() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('menuItems')
        .where('sellerID', isEqualTo: sellerId)
        .where('availability', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
  }

  Future<Seller?> fetchSellerDetails() async {
    var doc = await FirebaseFirestore.instance.collection('sellers').doc(sellerId).get();
    if (doc.exists) {
      return Seller.fromFirestore(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Seller?>(
      future: fetchSellerDetails(),
      builder: (context, sellerSnapshot) {
        if (sellerSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final seller = sellerSnapshot.data;
        final appBarTitle = seller != null ? '${seller.stallName}, ${seller.stallLocation}' : 'Menu';

        return Scaffold(
          appBar: AppBar(
            title:  Text(appBarTitle),
            actions: <Widget>[
              TextButton(
                onPressed: () => _navigateToRatingsAndReviews(context, sellerId),
                child: const Text('Ratings and Reviews',
                  style: TextStyle(
                    color: Colors.blue, // Makes it look like a hyperlink
                    decoration: TextDecoration.underline, // Underline decoration
                  ),
                ),
              ),
            ],
          ),

          body:

          FutureBuilder<List<MenuItem>>(
            future: fetchMenuItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No menu items found'));
              }
              List<MenuItem> menuItems = snapshot.data!;
              return ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  MenuItem menuItem = menuItems[index];
                  return ListTile(
                    title: Text(menuItem.itemName),
                    subtitle: Text(menuItem.itemCategory),
                    trailing: const Icon(
                      Icons.add,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsPage(menuItem: menuItem),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: Consumer<CartProvider>(builder: (context, cartProvider, child) {
          // No need to fetch seller details again if you have them from the FutureBuilder above.
          final sellerDetails = sellerSnapshot.data;
          if (sellerDetails == null) {
            return Container(); // Or some other widget in case the seller details are not available.
          }
          final itemsFromThisSeller = cartProvider.items.where((item) => item.item.sellerID == sellerDetails.id).toList();

          return itemsFromThisSeller.isNotEmpty
              ? FloatingActionButton.extended(
            onPressed: () {
              // Navigate directly to OrderConfirmationPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderConfirmationPage(
                    seller: sellerDetails,
                    cartItems: itemsFromThisSeller,
                  ),
                ),
              );
            },
            label: Text('Review Order (${itemsFromThisSeller.length})'),
            icon: const Icon(Icons.shopping_cart),
          )
              : Container(); // In case there are no items from this seller in the cart.
        }),
        );
      },
    );
  }

  void _navigateToRatingsAndReviews(BuildContext context, String sellerId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RatingsAndReviewsPage(sellerId: sellerId),
      ),
    );
  }
}