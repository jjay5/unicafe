import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/list_menu.dart';

import 'cart_item.dart';

class ListStallPage extends StatelessWidget {
  const ListStallPage({super.key});

  Future<List<Seller>> fetchSellers() async {
    var snapshot = await FirebaseFirestore.instance.collection('sellers').get();
    return snapshot.docs.map((doc) => Seller.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
          ],

        ),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'CAFETERIAS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Seller>>(
              future: fetchSellers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('No stalls found'));
                }
                List<Seller> sellers = snapshot.data!;
                return ListView.builder(
                  itemCount: sellers.length,
                  itemBuilder: (context, index) {
                    Seller seller = sellers[index];
                    return ListTile(
                      title: Text(seller.stallName),
                      subtitle: Text(seller.stallLocation),
                      onTap: () {
// Navigate to MenuPage with selected seller's ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuPage(sellerId: seller.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
