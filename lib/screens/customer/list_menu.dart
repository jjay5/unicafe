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

  Future<Map<String, List<MenuItem>>> fetchMenuItemsByCategory() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('menuItems')
        .where('sellerID', isEqualTo: sellerId)
        .where('availability', isEqualTo: true)
        .get();

    Map<String, List<MenuItem>> menuItemsByCategory = {};

    for (var doc in snapshot.docs) {
      var menuItem = MenuItem.fromFirestore(doc);
      if (menuItemsByCategory.containsKey(menuItem.itemCategory)) {
        menuItemsByCategory[menuItem.itemCategory]!.add(menuItem);
      } else {
        menuItemsByCategory[menuItem.itemCategory] = [menuItem];
      }
    }

    return menuItemsByCategory;
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
          ),

          body: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => _navigateToRatingsAndReviews(context, sellerId),
            child: const Text(
              'Ratings and Reviews',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                //decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
                Expanded(
                  child: FutureBuilder<Map<String, List<MenuItem>>>(
                    future: fetchMenuItemsByCategory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No menu items found'));
                      }
                      Map<String, List<MenuItem>> menuItemsByCategory = snapshot.data!;

                      return ListView.builder(
                        itemCount: menuItemsByCategory.length,
                        itemBuilder: (context, index) {
                          var category = menuItemsByCategory.keys.toList()[index];
                          var menuItems = menuItemsByCategory[category]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: menuItems.length,
                                itemBuilder: (context, index) {
                                  final menuItem = menuItems[index];
                                  return ListTile(
                                    leading: menuItem.itemPhoto != null && menuItem.itemPhoto!.isNotEmpty
                                        ? Container(
                                      width: 50.0, // Set your desired width
                                      height: 50.0, // Set your desired height to make it square
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle, // This is optional, or you can use BoxShape.circle for circles
                                        image: DecorationImage(
                                          fit: BoxFit.cover, // This will fill the bounds of the container without changing the aspect ratio of the image
                                          image: NetworkImage(menuItem.itemPhoto!),
                                        ),
                                      ),
                                    )
                                        : Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage('assets/images/default_image.png'),
                                        ),
                                      ),
                                    ),

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
                                separatorBuilder: (context, index) => const Divider(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
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