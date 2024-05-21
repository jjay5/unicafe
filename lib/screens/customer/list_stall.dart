import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/customer/list_menu.dart';
import 'package:unicafe/screens/customer/cart_item.dart';

class ListStallPage extends StatefulWidget {
  const ListStallPage({super.key});

  @override
  ListStallPageState createState() => ListStallPageState();
}

class ListStallPageState extends State<ListStallPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Seller>>? _sellersFuture;

  @override
  void initState() {
    super.initState();
    _sellersFuture = fetchSellers();
    _searchController.addListener(() {
      setState(() {
        _sellersFuture = fetchSellers(query: _searchController.text);
      });
    });
  }

  Future<List<Seller>> fetchSellers({String query = ''}) async {
    var snapshot = await FirebaseFirestore.instance.collection('sellers').get();
    List<Seller> sellers = snapshot.docs.map((doc) => Seller.fromFirestore(doc)).toList();

    if (query.isNotEmpty) {
      sellers = sellers.where((seller) {
        return seller.stallName.toLowerCase().contains(query.toLowerCase()) ||
            seller.stallLocation.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    return sellers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Stalls',
                      border: InputBorder.none,
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
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
              future: _sellersFuture,
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