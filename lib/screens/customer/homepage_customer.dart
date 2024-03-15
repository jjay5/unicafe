import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/screens/customer/list_stall.dart';
import 'package:unicafe/screens/customer/update_customer.dart';
import 'package:unicafe/screens/customer/list_menu.dart';

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

  // Define your pages here
  final List<Widget> _pageOptions = <Widget>[
    const ListStallPage(), // Home widget
    const Text("Order"), //Order widget
    const UpdateCustomerPage(), // Account Page widget
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack( // Use IndexedStack to maintain state of each page
        index: _selectedIndex,
        children: _pageOptions,
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

/*
class Home extends StatelessWidget{
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final customer = customerProvider.customer;

    return Scaffold(
      appBar: AppBar(

        title: customer != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${customer.name}',
              style: const TextStyle(
                fontSize: 20, // Change the font size
                fontWeight: FontWeight.bold, // Make the text bold
              ),)
          ],
        )
            : const Text('Customer not found'),
      ),
    );
  }
}
*/
