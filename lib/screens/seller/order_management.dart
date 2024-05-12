import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/order.dart';
import 'package:unicafe/screens/seller/order_details_seller.dart';

class OrderManagementPage extends StatefulWidget {
  final String sellerID;

  const OrderManagementPage({super.key, required this.sellerID});

  @override
  OrderManagementPageState createState() => OrderManagementPageState();
}

class OrderManagementPageState extends State<OrderManagementPage> {
  late Stream<List<Orders>> _pendingOrdersStream;
  late Stream<List<Orders>> _preparingOrdersStream;
  late Stream<List<Orders>> _readyToPickupOrdersStream;
  late Stream<List<Orders>> _completedOrdersStream;

  @override
  void initState() {
    super.initState();
    _pendingOrdersStream = _getOrdersStream('pending');
    _preparingOrdersStream = _getOrdersStream('preparing');
    _readyToPickupOrdersStream = _getOrdersStream('ready to pickup');
    _completedOrdersStream = _getOrdersStream('completed');
  }

  Stream<List<Orders>> _getOrdersStream(String status) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('sellerID', isEqualTo: widget.sellerID)
        .where('orderStatus', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Orders.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Adjust the font size as needed
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Preparing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Adjust the font size as needed
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Ready to \nPickup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Adjust the font size as needed
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Adjust the font size as needed
                    ),
                  ),
                ),
              ],
            ),

            // Header
            const SizedBox(height: 15),
            const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text('Order ID',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, // Underlined like a hyperlink
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ),
                Expanded(
                  flex: 2,
                  child: Text('Items',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, // Underlined like a hyperlink
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Order Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, // Underlined like a hyperlink
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrdersList(_pendingOrdersStream),
                  _buildOrdersList(_preparingOrdersStream),
                  _buildOrdersList(_readyToPickupOrdersStream),
                  _buildOrdersList(_completedOrdersStream),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(Stream<List<Orders>> stream) {
    return StreamBuilder<List<Orders>>(
      stream: stream,
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
    );
  }
}

class OrderListItem extends StatelessWidget {
  final Orders order;

  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Navigate to order detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order details
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${order.id}',
                      //textAlign: TextAlign.center,
                      style: const TextStyle(
                        decoration: TextDecoration.underline, // Underlined like a hyperlink
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: StreamBuilder<List<OrderItem>>(
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
                            '${item.quantity}x ${item.menuItem.itemName} \n${item.notes}\n',
                          ))
                              .toList(),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<String>(
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
                  ),
                ],
              ),
              // Divider
              const Divider(),
            ],
          ),
        )
    );
  }

  void _updateOrderStatus(BuildContext context, Orders order, String newStatus) {

    order.updateOrderStatus(newStatus);

    // Show a success message or handle errors as needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order status updated successfully!')),
    );
  }
}



