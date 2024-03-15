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
  _MenuListPageState createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
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
            .where('availability', isEqualTo: true) // Only get available items
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
                      image: NetworkImage('https://th.bing.com/th/id/OIP.DSvrEGChdMh67YH0GPo4TQAAAA?rs=1&pid=ImgDetMain'),
                    ),
                  ),
                ),


                title: Text(menuItem.itemName),
                subtitle: Text(menuItem.itemCategory),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdateMenuItemPage(menuItem: menuItem)),
                        );
                      },
                    ),
                    ElevatedButton(
                      //icon: Icon(Icons.delete),
                      onPressed: () async {
                        await delistMenuItem(menuItem.id!);
                        // No need to manually refresh, StreamBuilder will react to the data change
                      },
                      child: const Text('Delist'),
                    ),
                  ],
                ),
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
            MaterialPageRoute(builder: (context) => AddMenuItemPage()), // Adjust this to your actual "Add New Item" page
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Item',
      ),
    );
  }

  Future<void> delistMenuItem(String menuItemId) async {
    try {
      await FirebaseFirestore.instance.collection('menuItems').doc(menuItemId).update({'availability': false});
      // The UI will automatically update due to the StreamBuilder reacting to the data change
    } catch (e) {
      print('Error delisting menu item: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error delisting menu item: $e'),
      ));
    }
  }
}