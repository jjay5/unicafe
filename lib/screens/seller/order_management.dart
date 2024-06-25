import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/order.dart';
import 'package:unicafe/screens/seller/order_details_seller.dart';

class OrderManagementPage extends StatefulWidget {
  final String sellerID;
  final int initialTabIndex;

  const OrderManagementPage({
    super.key,
    required this.sellerID,
    this.initialTabIndex = 0  // Default to the first tab if not specified
  });

  @override
  OrderManagementPageState createState() => OrderManagementPageState();
}

class OrderManagementPageState extends State<OrderManagementPage> {
  late int _selectedTabIndex;

  late Stream<List<Orders>> _pendingOrdersStream;
  late Stream<List<Orders>> _preparingOrdersStream;
  late Stream<List<Orders>> _readyToPickupOrdersStream;
  late Stream<List<Orders>> _completedOrdersStream;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
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
        initialIndex: _selectedTabIndex,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Preparing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Ready to \nPickup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ),
                Expanded(
                  flex: 2,
                  child: Text('Pick Up Time',
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
                  _buildOrdersList(_pendingOrdersStream, 'No pending orders'),
                  _buildOrdersList(_preparingOrdersStream, 'No orders are being prepared'),
                  _buildOrdersList(_readyToPickupOrdersStream, 'No orders are ready for pickup'),
                  _buildOrdersList(_completedOrdersStream, 'No completed orders'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(Stream<List<Orders>> stream, String statusMessage) {
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
        if (orders.isEmpty) {
          return Center(
            child: Text(
              statusMessage,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        }
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
                  child:  Text(order.pickupTime),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order status updated successfully!')),
    );
  }
}