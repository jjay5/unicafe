import 'package:flutter/material.dart';

import '../../models/order.dart';

class OrderDetailPage extends StatelessWidget {
  final Orders order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order ID: ${order.id}'),
          const SizedBox(height: 8),
          const Text('Items:'),
          StreamBuilder<List<OrderItem>>(
            stream: order.getOrderItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final orderItems = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: orderItems
                    .map((item) => Text(
                  '- ${item.menuItemId}, Quantity: ${item.quantity}',
                ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          Text('Order Status: ${order.orderStatus}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _updateOrderStatus(context, order, 'preparing');
            },
            child: const Text('Update Order Status to Preparing'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _updateOrderStatus(context, order, 'ready to pickup');
            },
            child: const Text('Update Order Status to Ready to Pickup'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _updateOrderStatus(context, order, 'completed');
            },
            child: const Text('Update Order Status to Completed'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, Orders order, String newStatus) {
    // Implement logic to update order status here
    order.updateOrderStatus(newStatus);
    // Show a success message or handle errors as needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order status updated successfully!')),
    );
  }
}