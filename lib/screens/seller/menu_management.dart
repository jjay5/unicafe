import 'package:flutter/material.dart';
import 'package:unicafe/screens/seller/list_menu_management.dart';
import 'package:unicafe/screens/seller/delist_menu_management.dart';

class MenuManagementPage extends StatefulWidget {
  @override
  _MenuManagementPageState createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Menu Management"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Menu List"),
              Tab(text: "Delist Menu"),
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