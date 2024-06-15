import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/screens/login.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateValidation);
    _phoneController.addListener(_updateValidation);
    _emailController.addListener(_updateValidation);
    _passwordController.addListener(_updateValidation);
    _reEnterPasswordController.addListener(_updateValidation);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateValidation);
    _phoneController.removeListener(_updateValidation);
    _emailController.removeListener(_updateValidation);
    _passwordController.removeListener(_updateValidation);
    _reEnterPasswordController.removeListener(_updateValidation);

    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();

    super.dispose();
  }

  void _updateValidation() {
    setState(() {}); // Update UI when fill the form
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  bool isValidPhone(String value) {
    // Regex pattern for phone number with 8 to 10 digits
    final RegExp phoneRegExp = RegExp(r'^\d{8,10}$');
    return phoneRegExp.hasMatch(value);
  }

  //Email validation
  bool _isValidEmail(String email) {
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Please enter your email';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  bool _obscurePassword = true;
  bool _obscureReEnterPassword = true;

  //Password validation
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

  List<String?> _validatePass(String? value) {
    List<String?> errors = [];

    if (!_isAtLeast6Characters) {
      errors.add('Password must be at least 6 characters');
    }
    if (!_hasUpperCase) {
      errors.add('Password must contain at least one uppercase letter');
    }
    if (!_hasLowerCase) {
      errors.add('Password must contain at least one lowercase letter');
    }
    if (!_hasNumber) {
      errors.add('Password must contain at least one number');
    }
    if (!_hasSymbol) {
      errors.add('Password must contain at least one symbol: !@#\$%&*');
    }
    return errors;
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value!.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget buildPasswordRequirements() {
    List<String?> errors = _validatePass(_passwordController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (errors.isNotEmpty) ...errors.map((error) => Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 5),
            Flexible(child: Text(error ?? '', style: const TextStyle(color: Colors.red))),
          ],
        )),
      ],
    );
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
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    suffixIcon: _nameController.text.isEmpty
                        ? const Icon(Icons.error, color: Colors.red)  // Error icon if empty
                        : const Icon(Icons.check, color: Colors.green),  // Check icon if not empty
                  ),
                  validator: _validateName,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixText: '+60 ',
                    suffixIcon: _phoneController.text.isEmpty
                        ? const Icon(Icons.error, color: Colors.red)  // Error icon if empty
                        : isValidPhone(_phoneController.text)
                        ? const Icon(Icons.check, color: Colors.green) // Check icon if email is valid
                        : const Icon(Icons.error, color: Colors.red),
                  ),
                  validator: _validatePhone,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    suffixIcon: _emailController.text.isEmpty
                        ? const Icon(Icons.error, color: Colors.red)  // Error icon if empty
                        : _isValidEmail(_emailController.text)
                          ? const Icon(Icons.check, color: Colors.green) // Check icon if email is valid
                          : const Icon(Icons.error, color: Colors.red),
                  ),
                  validator: _validateEmail,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (value) {
                        _validatePassword(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_passwordController.text.isNotEmpty &&
                                _isAtLeast6Characters &&
                                _hasUpperCase &&
                                _hasLowerCase &&
                                _hasNumber &&
                                _hasSymbol)
                              const Icon(Icons.check, color: Colors.green)
                            else if (_passwordController.text.isNotEmpty)
                              const Icon(Icons.error, color: Colors.red),
                            IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'See requirements below';
                        }
                        if (!_isAtLeast6Characters ||
                            !_hasUpperCase ||
                            !_hasLowerCase ||
                            !_hasNumber ||
                            !_hasSymbol) {
                          return 'See requirements below';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    buildPasswordRequirements(), // Display all password requirement dynamically
                  ],
                ),
                TextFormField(
                  controller: _reEnterPasswordController,
                  obscureText: _obscureReEnterPassword,
                  decoration: InputDecoration(
                    labelText: 'Re-enter Password',
                    hintText: 'Re-enter password',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reEnterPasswordController.text.isNotEmpty &&
                            _reEnterPasswordController.text == _passwordController.text)
                          const Icon(Icons.check, color: Colors.green)
                        else if (_reEnterPasswordController.text.isNotEmpty)
                          const Icon(Icons.error, color: Colors.red),
                        IconButton(
                          icon: Icon(
                            _obscureReEnterPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureReEnterPassword = !_obscureReEnterPassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('FAILEDDDDDDDD'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text('Please fill all the requiredment'),
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