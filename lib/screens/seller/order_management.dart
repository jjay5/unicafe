import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/order.dart';

class OrderManagementPage extends StatefulWidget {
  final String sellerID;

  const OrderManagementPage({super.key, required this.sellerID});

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  late Stream<List<Orders>> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerID', isEqualTo: widget.sellerID)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Orders.fromFirestore(doc)).toList());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: StreamBuilder<List<Orders>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderListItem(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderListItem extends StatelessWidget {
  final Orders order;

  const OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Order ID: ${order.id}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  '- ${item.menuItem.itemName}, Quantity: ${item.quantity}',
                ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Order Status: '),
              DropdownButton<String>(
                value: order.orderStatus,
                onChanged: (newValue) {
                  // Update order status
                  _updateOrderStatus(context, order, newValue!);
                },
                items: ['pending', 'preparing', 'ready to pickup', 'completed']
                    .map<DropdownMenuItem<String>>((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        // Navigate to order detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(order: order),
          ),
        );
      },
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

class OrderDetailPage extends StatelessWidget {
  final Orders order;

  const OrderDetailPage({required this.order});

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

