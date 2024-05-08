import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';
import 'package:unicafe/screens/seller/update_seller.dart';
import 'package:unicafe/screens/seller/schedule.dart';

import 'order_management.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Seller App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final sellerID = sellerProvider.seller?.id ?? ''; // Get seller ID from SellerProvider

    List<Widget> pageOptions = <Widget>[
      const Home(), // Placeholder for HomePage widget
      MenuManagementPage(), // MenuPage widget
      OrderManagementPage(sellerID: sellerID),
      ModifyPickupSlotPage(seller: Provider.of<SellerProvider>(context, listen: false).seller!),
      const UpdateSellerPage(), // AccountPage widget
    ];
    return Scaffold(

      body: IndexedStack( // Use IndexedStack to maintain state of each page
        index: _selectedIndex,
        children: pageOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Pickup Times',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Count of orders by status
  Future<int> getCountOfOrdersByStatus(String sellerId, String status) async {
    var snapshot = await _db.collection('orders')
        .where('sellerID', isEqualTo: sellerId)
        .where('orderStatus', isEqualTo: status)
        .get();
    return snapshot.docs.length;
  }

  // Count of feedbacks for all orders
  Future<int> getCountOfFeedbacks(String sellerId) async {
    int feedbackCount = 0;

    // Fetch all orders for the given seller
    var ordersSnapshot = await _db.collection('orders')
        .where('sellerID', isEqualTo: sellerId)
        .get();

    // For each order, count the feedback entries
    for (var orderDoc in ordersSnapshot.docs) {
      var feedbackSnapshot = await orderDoc.reference.collection('feedback').get();
      feedbackCount += feedbackSnapshot.docs.length;
    }
    return feedbackCount;
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final seller = sellerProvider.seller;
    final orderService = Provider.of<OrderService>(context, listen: false);

    if (seller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seller not found')),
        body: const Center(child: Text('No seller selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  seller.stallName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  seller.stallLocation.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24, // You can adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _buildCard(
              title: 'Orders To Prepare',
              content: _buildOrderInfoTile(context, orderService, seller.id, 'pending'),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Completed Orders',
              content: _buildOrderInfoTile(context, orderService, seller.id, 'completed'),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Reviews',
              content: _buildFeedbackTile(context, orderService, seller.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoTile(BuildContext context, OrderService orderService, String sellerId, String status) {
    return FutureBuilder<int>(
      future: orderService.getCountOfOrdersByStatus(sellerId, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Text(
          '${snapshot.data ?? 0}',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }

  Widget _buildFeedbackTile(BuildContext context, OrderService orderService, String sellerId) {
    return FutureBuilder<int>(
      future: orderService.getCountOfFeedbacks(sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Text(
          '${snapshot.data ?? 0}',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}




