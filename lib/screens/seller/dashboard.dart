import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/screens/seller/homepage_seller.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/screens/seller/view_feedback.dart';

class Dashboard extends StatelessWidget {

  final Function(int) onSelectPage;

  const Dashboard({super.key, required this.onSelectPage});

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final seller = sellerProvider.seller;
    final orderService = Provider.of<OrderService>(context, listen: false);

    if (seller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seller not found')),
        body: const Center(child: Text('No seller selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    seller.stallName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    seller.stallLocation.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24, // You can adjust the font size as needed
                     // fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
             _buildCard(
                title: 'Orders To Prepare',
                content: _buildOrderInfoTile(context, orderService, seller.id, 'pending'),
                onTap: () => onSelectPage(2),
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: 'Completed Orders',
                content: _buildOrderInfoTile(context, orderService, seller.id, 'completed'),
                onTap: (){},
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: 'Reviews',
                content: _buildFeedbackTile(context, orderService, seller.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerFeedbackPage(sellerId: seller.id)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoTile(BuildContext context, OrderService orderService, String sellerId, String status) {
    return FutureBuilder<int>(
      future: orderService.getCountOfOrdersByStatus(sellerId, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Text(
          '${snapshot.data ?? 0}',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }

  Widget _buildFeedbackTile(BuildContext context, OrderService orderService, String sellerId) {
    return FutureBuilder<int>(
      future: orderService.getCountOfFeedbacks(sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Text(
          '${snapshot.data ?? 0}',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}