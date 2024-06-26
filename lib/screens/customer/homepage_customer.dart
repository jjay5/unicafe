import 'package:flutter/material.dart';
import 'package:unicafe/screens/customer/list_stall.dart';
import 'package:unicafe/screens/customer/update_customer.dart';
import 'package:unicafe/screens/customer/my_order.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Customer App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Use the initial index
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> pageOptions = <Widget>[
      const ListStallPage(), // Home widget
      const CustomerOrdersPage(),
      const UpdateCustomerPage(), // Account Page widget
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
            icon: Icon(Icons.receipt),
            label: 'Order',
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