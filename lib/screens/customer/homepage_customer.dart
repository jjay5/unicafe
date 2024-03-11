import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final customer = customerProvider.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: Center(
        child: customer != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Customer Name: ${customer.name}'),
            Text('Phone Number: ${customer.phone}'),
          ],
        )

            : const Text('Customer not found'),
      ),
    );
  }
}

