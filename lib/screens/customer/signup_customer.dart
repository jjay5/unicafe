import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/screens/login.dart';

/*
class SignUpCustomerPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignUpCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: _reEnterPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Re-enter Password'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Sign Up'),
                onPressed: () async {
                  try {
                    // Check if passwords match
                    if (_passwordController.text.trim() != _reEnterPasswordController.text.trim()) {
                      throw 'Passwords do not match';
                    }

                    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );

                    Customer newCustomer = Customer(
                      id: userCredential.user!.uid,
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      email: _emailController.text.trim(),
                    );

                    await _firestore.collection('customers').doc(userCredential.user!.uid).set(newCustomer.toMap());

                    // Notify user and navigate to login page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signup successful, please log in.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    // After successful signup
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );

                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(e.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
             ),
           ],
          ),
        ),
      ),
    );
  }
}
*/

class SignUpCustomerPage extends StatefulWidget {
  const SignUpCustomerPage({super.key});

  @override
  SignUpCustomerPageState createState() => SignUpCustomerPageState();
}

class SignUpCustomerPageState extends State<SignUpCustomerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  String? _validatePasswordConfirmation(String? value) {
    if (value != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _isAtLeast6Characters = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  void _validatePassword(String password) {
    setState(() {
      _isAtLeast6Characters = password.length >= 6;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSymbol = password.contains(RegExp(r'[!@#$%&*]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: _passwordController.text.isEmpty
                        ? null
                        : Icon(
                      _isAtLeast6Characters && _hasUpperCase && _hasLowerCase && _hasNumber && _hasSymbol
                          ? Icons.check
                          : Icons.error,
                      color: _isAtLeast6Characters && _hasUpperCase && _hasLowerCase && _hasNumber && _hasSymbol
                          ? Colors.green
                          : Colors.red,
                    ),
                    hintText: 'Enter your password',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password at least 6 characters with \nupper case, lower case, number, and symbol';
                    }
                    if (!_isAtLeast6Characters) {
                      return 'Password must be at least 6 characters';
                    }
                    if (!_hasUpperCase) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!_hasLowerCase) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!_hasNumber) {
                      return 'Password must contain at least one number';
                    }
                    if (!_hasSymbol) {
                      return 'Password must contain at least one symbol: !@#\$%&*';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _reEnterPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Re-enter Password'),
                  validator: _validatePasswordConfirmation,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Sign Up'),
                  onPressed: () async {
                      try {
                        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        Customer newCustomer = Customer(
                          id: userCredential.user!.uid,
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                        );

                        await _firestore.collection('customers').doc(userCredential.user!.uid).set(newCustomer.toMap());

                        // Notify user and navigate to login page
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signup successful, please log in.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // After successful signup
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );

                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



/*

class SignUpCustomerPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignUpCustomerPage({super.key});

  bool _isPasswordValid(String password) {
    // Regex to validate the password
    RegExp regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%*^?&()])[A-Za-z\d#$@!%*^?&()]{6,}$',
    );
    return regex.hasMatch(password);
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: _passwordController.text.isEmpty
                        ? null
                        : Icon(
                      _isAtLeast6Characters && _hasUpperCase && _hasLowerCase && _hasNumber && _hasSymbol
                          ? Icons.check
                          : Icons.error,
                      color: _isAtLeast6Characters && _hasUpperCase && _hasLowerCase && _hasNumber && _hasSymbol
                          ? Colors.green
                          : Colors.red,
                    ),
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_isAtLeast6Characters) {
                      return 'Password must be at least 6 characters';
                    }
                    if (!_hasUpperCase) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!_hasLowerCase) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!_hasNumber) {
                      return 'Password must contain at least one number';
                    }
                    if (!_hasSymbol) {
                      return 'Password must contain at least one symbol: !@#\$%&*';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _reEnterPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Re-enter Password'),
                  validator: _validatePasswordConfirmation,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Sign Up'),
                  onPressed: () async {
                    if (Form.of(context)!.validate()) {
                      try {
                        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        Customer newCustomer = Customer(
                          id: userCredential.user!.uid,
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                        );

                        await _firestore.collection('customers').doc(userCredential.user!.uid).set(newCustomer.toMap());

                        // Notify user and navigate to login page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signup successful, please log in.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // After successful signup
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );

                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/