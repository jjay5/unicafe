import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/item_detail.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';

class MenuPage extends StatelessWidget {
  final String sellerId;

  MenuPage({required this.sellerId});

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
              title: Text('Loading...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final seller = sellerSnapshot.data;
        final appBarTitle = seller != null ? '${seller.stallName}, ${seller.stallLocation}' : 'Menu';

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
          ),
          body: FutureBuilder<List<MenuItem>>(
            future: fetchMenuItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No menu items found'));
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
        );
      },
    );
  }
}