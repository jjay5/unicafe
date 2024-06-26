import 'package:flutter/material.dart';
import 'package:unicafe/screens/seller/list_menu_management.dart';
import 'package:unicafe/screens/seller/delist_menu_management.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  MenuManagementPageState createState() => MenuManagementPageState();
}

class MenuManagementPageState extends State<MenuManagementPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Menu Management"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Live"),
              Tab(text: "Delisted"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1 content
            MenuListPage(),
            // Tab 2 content
            MenuDelistPage(),
          ],
        ),
      ),
    );
  }
}