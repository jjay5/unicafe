import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unicafe/services/firebase_options.dart';
import 'package:unicafe/screens/login.dart';
import 'package:unicafe/screens/customer/signup_customer.dart';
import 'package:unicafe/screens/seller/signup_seller.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/models/menu_item.dart';
import 'package:unicafe/models/cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SellerProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Center the buttons vertically
          children: [
            ElevatedButton(
              child: const Text('Go to Customer Sign Up'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpCustomerPage()),
                );
              },
            ),
            const SizedBox(height: 20), // Add some space between the buttons
            ElevatedButton(
              child: const Text('Go to Seller Sign Up'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpSellerPage()),
                );
              },
            ),
            const SizedBox(height: 20), // Add some space between the buttons
            ElevatedButton(
              child: const Text('Go to Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}