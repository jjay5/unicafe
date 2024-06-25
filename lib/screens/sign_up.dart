import 'package:flutter/material.dart';
import 'package:unicafe/screens/seller/signup_seller.dart';
import 'package:unicafe/screens/customer/signup_customer.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Center the buttons vertically
          children: [
            const Text(
              'SIGN UP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold, // Make the text bold
              ),
            ),
            const SizedBox(height: 30.0),
            const Text('Please select your role'),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, // Set width to match parent width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Customer'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpCustomerPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20), // Add some space between the buttons
            SizedBox(
              width: 200, // Set width to match parent width
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Seller'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpSellerPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}