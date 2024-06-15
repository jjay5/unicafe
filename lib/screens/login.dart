import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unicafe/screens/seller/homepage_seller.dart';
import 'package:unicafe/screens/customer/homepage_customer.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/services/user_service.dart';
import 'package:unicafe/screens/sign_up.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'UNICAFE',
              style: TextStyle(
                fontSize: 50, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not a User Yet?'),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    ' Sign Up Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Make the text blue to indicate it's clickable
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                _showForgotPasswordDialog();
              },
              child: const Text(
                'Forgot Password?',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  //decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final UserService userService = UserService();

      // Retrieve user role from Firestore
      String role = await userService.getUserRole(userCredential.user!.uid);

      if (role == 'customer') {
        Customer? customer = await userService.fetchCustomerDetails(userCredential.user!.uid);
        if (customer != null) {
          // Set customer provider
          if (!mounted) return;
          Provider.of<CustomerProvider>(context, listen: false).setCustomer(customer);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomePage()));
        } else {
          // Handle customer not found
          if (kDebugMode) {
            print('Customer details not found');
          }
        }
      } else if (role == 'seller') {
        Seller? seller = await userService.fetchSellerDetails(userCredential.user!.uid);
        if (seller != null) {
          // Set seller provider
          if (!mounted) return;
          Provider.of<SellerProvider>(context, listen: false).setSeller(seller);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  const SellerHomePage()));
        } else {
          // Handle seller not found
          if (kDebugMode) {
            print('Seller details not found');
          }
        }
      } else {
        // Handle unknown role
        if (kDebugMode) {
          print('Unknown role');
        }
      }
    } catch (e) {
      // Handle login errors
      if (kDebugMode) {
        print('Login Error: $e');
      }
      // Show error message to the user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to login. Please check your credentials.'),
      ));
    }
  }
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController forgotPasswordController = TextEditingController();

        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextField(
            controller: forgotPasswordController,
            decoration: const InputDecoration(labelText: 'Enter your email'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _resetPassword(forgotPasswordController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Password Reset Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not send password reset email')),
      );
    }
  }
}