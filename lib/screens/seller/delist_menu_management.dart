import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/menu_item.dart';

class MenuDelistPage extends StatefulWidget {
  @override
  _MenuDelistPageState createState() => _MenuDelistPageState();
}

class _MenuDelistPageState extends State<MenuDelistPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _delistItem(String itemId) {
    _firestore.collection('menuItems').doc(itemId).update({'availability': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu List"),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('menuItems').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              MenuItem item = MenuItem.fromMap(document.data() as Map<String, dynamic>);
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit item page
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () => _delistItem(item.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
