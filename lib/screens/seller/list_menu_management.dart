import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/add_menu.dart';
import 'package:unicafe/screens/seller/update_menu.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  MenuListPageState createState() => MenuListPageState();
}

class MenuListPageState extends State<MenuListPage> {
  @override
  Widget build(BuildContext context) {
    final seller = Provider.of<SellerProvider>(context).seller;
    final String? sellerID = seller?.id; // Get the current seller's ID

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menuItems')
            .where('sellerID', isEqualTo: sellerID)
            .where('availability', isEqualTo: true) // Only get available items
            .where('isDeleted', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final menuItems = snapshot.data!.docs
              .map((doc) => MenuItem.fromFirestore(doc))
              .toList();

          if (menuItems.isEmpty) {
            return const Center(child: Text('No Menu Items'));
          }
// Group items by category
          final Map<String, List<MenuItem>> categorizedMenuItems = {};
          for (var menuItem in menuItems) {
            categorizedMenuItems.putIfAbsent(menuItem.itemCategory, () => []).add(menuItem);
          }

          return ListView.builder(
            itemCount: categorizedMenuItems.keys.length,
            itemBuilder: (context, index) {
              final category = categorizedMenuItems.keys.elementAt(index);
              final items = categorizedMenuItems[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map((menuItem) {
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RM${menuItem.price.toStringAsFixed(2)}'),
                          Text('${menuItem.durationToCook} minutes'), // Additional text below the price
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await delistMenuItem(menuItem.id!);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item delisted successfully'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('Delist'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => UpdateMenuItemPage(menuItem: menuItem)),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              // Confirm dialog before deleting
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text('Are you sure you want to delete this item?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false); // Dismiss and return false
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true); // Dismiss and return true
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete) {
                                await deleteMenuItem(menuItem.id!);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item deleted successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to navigate to the add new item page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMenuItemPage()),
          );
        },
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> delistMenuItem(String menuItemId) async {
    try {
      await FirebaseFirestore.instance.collection('menuItems').doc(menuItemId).update({'availability': false});
      // The UI will automatically update due to the StreamBuilder reacting to the data change
    } catch (e) {
      if (kDebugMode) {
        print('Error delisting menu item: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error delisting menu item: $e'),
      ));
    }
  }

  Future<void> deleteMenuItem(String id) async {
    await FirebaseFirestore.instance.collection('menuItems').doc(id).update({'isDeleted': true});
  }
}