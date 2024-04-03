import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/list_menu.dart';

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
        title: const Text('Cafeterias'),
      ),
      body: FutureBuilder<List<Seller>>(
        future: fetchSellers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No stalls found'));
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
    );
  }
}