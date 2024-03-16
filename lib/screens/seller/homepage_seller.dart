import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/menu_management.dart';
import 'package:unicafe/screens/seller/update_seller.dart';
import 'package:unicafe/screens/seller/schedule.dart';

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
    List<Widget> pageOptions = <Widget>[
      const Home(), // Placeholder for your HomePage widget
      MenuManagementPage(), // Your actual MenuPage widget
      const Text('Order Page'), // Your actual OrderPage widget
      ModifyPickupSlotPage(seller: Provider.of<SellerProvider>(context, listen: false).seller!), // Now context is used within build, so it's safe
      const UpdateSellerPage(), // Your actual AccountPage widget
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

class Home extends StatelessWidget{
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final seller = sellerProvider.seller;

    return Scaffold(
      appBar: AppBar(

        title: seller != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${seller.stallName.toUpperCase()}, ${seller.stallLocation.toUpperCase()}',
            style: const TextStyle(
              fontSize: 30, // Change the font size
              fontWeight: FontWeight.bold, // Make the text bold
            ),)
          ],
        )
            : const Text('Seller not found'),
      ),
    );
  }
}