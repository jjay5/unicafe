import 'package:flutter/material.dart';
import 'package:unicafe/main.dart';
import 'package:unicafe/screens/customer/update_customer.dart';
import 'package:unicafe/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                dynamic result = await _auth.signIn(_emailController.text, _passwordController.text);
                if (result != null) {
                  // Navigate to the HomePage if login is successful
                  Navigator.pushReplacement( // or Navigator.push for non-replacement
                    context,
                    MaterialPageRoute(builder: (context) => UpdateCustomerPage()),
                  );
                } else {
                  // Display error message if login fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login Failed. Please check your email and password.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}