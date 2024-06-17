import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/update_menu.dart';

class MenuDelistPage extends StatefulWidget {
  const MenuDelistPage({super.key});

  @override
  MenuDelistPageState createState() => MenuDelistPageState();
}

class MenuDelistPageState extends State<MenuDelistPage> {
  @override
  Widget build(BuildContext context) {
    final seller = Provider.of<SellerProvider>(context).seller;
    final String? sellerID = seller?.id; // Get the current seller's ID

    return Scaffold(
      /* appBar: AppBar(
        title: Text('Menu Management'),
      ),*/
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menuItems')
            .where('sellerID', isEqualTo: sellerID)
            .where('availability', isEqualTo: false) // Only get available items
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
          return ListView.builder(
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      //icon: Icon(Icons.delete),
                      onPressed: () async {
                        await publishMenuItem(menuItem.id!);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item published successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Publish'),
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
            },
          );
        },
      ),
    );
  }

  Future<void> publishMenuItem(String menuItemId) async {
    try {
      await FirebaseFirestore.instance.collection('menuItems').doc(menuItemId).update({'availability': true});
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
    await FirebaseFirestore.instance.collection('menuItems').doc(id).delete();
  }
}