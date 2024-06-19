import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/item_detail.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/screens/customer/ratings_reviews.dart';
import 'package:unicafe/screens/customer/order_confirmation.dart';

class MenuPage extends StatefulWidget {
  final String sellerId;

  const MenuPage({super.key, required this.sellerId});

  @override
  MenuPageState createState() => MenuPageState();
}

class MenuPageState extends State<MenuPage> {
  late Future<Map<String, List<MenuItem>>> _menuItemsFuture;
  late Future<Seller?> _sellerFuture;
  String _searchQuery = '';
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = fetchMenuItemsByCategory();
    _sellerFuture = fetchSellerDetails();
  }

  Future<Map<String, List<MenuItem>>> fetchMenuItemsByCategory() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('menuItems')
        .where('sellerID', isEqualTo: widget.sellerId)
        .where('availability', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
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
    var doc = await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerId).get();
    if (doc.exists) {
      return Seller.fromFirestore(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Seller?>(
      future: _sellerFuture,
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
            title: Text(appBarTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                  });
                },
              ),
            ],
            bottom: _showSearchBar
            ? PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search menu items ...',
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    ),
                  ),
                ),
              ),
            )
                : null,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => _navigateToRatingsAndReviews(context, widget.sellerId),
                  child: const Text(
                    'Ratings and Reviews',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, List<MenuItem>>>(
                  future: _menuItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No menu items found'));
                    }
                    Map<String, List<MenuItem>> menuItemsByCategory = snapshot.data!;
                    Map<String, List<MenuItem>> filteredItemsByCategory = _filterMenuItems(menuItemsByCategory, _searchQuery);

                    return ListView.builder(
                      itemCount: filteredItemsByCategory.length,
                      itemBuilder: (context, index) {
                        var category = filteredItemsByCategory.keys.toList()[index];
                        var menuItems = filteredItemsByCategory[category]!;

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
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
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
                                  subtitle: Text('RM${menuItem.price.toStringAsFixed(2)}'),
                                  trailing: const Icon(Icons.add),
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
          floatingActionButton: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final sellerDetails = sellerSnapshot.data;
              if (sellerDetails == null) {
                return Container();
              }
              final itemsFromThisSeller = cartProvider.items.where((item) => item.item.sellerID == sellerDetails.id).toList();

              return itemsFromThisSeller.isNotEmpty
                  ? FloatingActionButton.extended(
                onPressed: () {
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
                  : Container();
            },
          ),
        );
      },
    );
  }

  Map<String, List<MenuItem>> _filterMenuItems(Map<String, List<MenuItem>> menuItemsByCategory, String query) {
    if (query.isEmpty) {
      return menuItemsByCategory;
    }

    Map<String, List<MenuItem>> filteredItemsByCategory = {};
    menuItemsByCategory.forEach((category, items) {
      List<MenuItem> filteredItems = items.where((item) => item.itemName.toLowerCase().contains(query.toLowerCase())).toList();
      if (filteredItems.isNotEmpty) {
        filteredItemsByCategory[category] = filteredItems;
      }
    });

    return filteredItemsByCategory;
  }

  void _navigateToRatingsAndReviews(BuildContext context, String sellerId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RatingsAndReviewsPage(sellerId: sellerId),
      ),
    );
  }
}