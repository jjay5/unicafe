import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';
import 'package:unicafe/screens/seller/update_seller.dart';
import 'package:unicafe/screens/seller/schedule.dart';
import 'package:unicafe/screens/seller/order_management.dart';
import 'package:unicafe/screens/seller/dashboard.dart';

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

  void navigateToPage(int index) {
    setState(() {
      _selectedIndex = index; // This changes the current page index
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final sellerID = sellerProvider.seller?.id ?? ''; // Get seller ID from SellerProvider

    List<Widget> pageOptions = <Widget>[
      Dashboard(onSelectPage: navigateToPage),
      const MenuManagementPage(),
      OrderManagementPage(sellerID: sellerID),
      ModifyPickupSlotPage(seller: Provider.of<SellerProvider>(context, listen: false).seller!),
      const UpdateSellerPage(),
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