import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/models/order.dart';
import 'package:unicafe/screens/customer/add_feedback.dart';
import 'package:unicafe/screens/customer/view_feedback.dart';
import 'package:unicafe/screens/customer/order_details_customer.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  CustomerOrdersPageState createState() => CustomerOrdersPageState();
}

class CustomerOrdersPageState extends State<CustomerOrdersPage>{
  String selectedStatus = 'all'; // Default to show all orders

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final customer = customerProvider.customer;

    if (customer == null) {
      return const Scaffold(
        body: Center(
          child: Text("No customer signed in"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>['all', 'pending', 'preparing', 'ready to pickup', 'completed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              elevation: 8,
            ),
          ),
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: _getOrderStream(customer.id, selectedStatus),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error.toString()}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  String orderStatus = data['orderStatus'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('sellers').doc(data['sellerID']).get(),
                    builder: (context, sellerSnapshot) {
                      if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Order ID: ${doc.id}'),
                          subtitle: const Text('Loading customer details...'),
                        );
                      }
                      if (sellerSnapshot.hasError) {
                        return ListTile(
                          title: Text('Order ID: ${doc.id}'),
                          subtitle: const Text('Error loading customer details'),
                        );
                      }
                      if (!sellerSnapshot.hasData) {
                        return ListTile(
                          title: Text('Order ID: ${doc.id}'),
                          subtitle: const Text('Customer details not found'),
                        );
                      }
                      Map<String, dynamic> sellerData = sellerSnapshot.data!.data() as Map<String, dynamic>;
                      bool isCompleted = orderStatus == 'completed';

                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                _getStatusMessage(orderStatus),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 8.0),
                            _buildOrderStatusIndicator(orderStatus),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 8.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailPage(order: Orders.fromSnapshot(doc)), // Pass Orders object to OrderDetailPage
                                    ),
                                );
                              },
                              child: Text('Order ID: ${doc.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              'Order Date: ${DateFormat('MMMM dd, yyyy \'at\' h:mm:ss a').format(data['orderDate'].toDate())}',
                            ),
                            const SizedBox(height: 8.0),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('Pick Up At:'),
                                ),
                                Expanded(
                                  child: Text('Total Amount:'),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${sellerData['stallName']}, ${sellerData['stallLocation']}'),
                                ),
                                Expanded(
                                  child: Text('RM ${data['totalAmount'].toStringAsFixed(2)}'),
                                ),
                              ],
                            ),
                            if (isCompleted)
                              if (isCompleted)
                                FutureBuilder<bool>(
                                  future: hasReviewedOrder(doc.id),
                                  builder: (context, reviewSnapshot) {
                                    if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (reviewSnapshot.hasError) {
                                      return const Text('Error loading review status');
                                    }
                                    bool hasReviewed = reviewSnapshot.data ?? false;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => hasReviewed
                                                    ? ViewFeedbackPage(orderId: doc.id)
                                                    : FeedbackPage(orderId: doc.id)
                                            ),
                                          );
                                        },
                                        child: Text(
                                          hasReviewed ? 'My Reviews' : 'Rate this order',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),)
        ],
      ),
      
    );
  }
}

Stream<QuerySnapshot> _getOrderStream(String customerId, String status) {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  Query query = orders.where('customerID', isEqualTo: customerId);

  if (status != 'all') {
    query = query.where('orderStatus', isEqualTo: status);
  }

  query = query.orderBy('orderDate', descending: true);
  return query.snapshots();
}

  Future<bool> hasReviewedOrder(String orderId) async {
    final reviewSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .collection('feedback')
        .get();

    return reviewSnapshot.docs.isNotEmpty;
  }

  Widget _buildOrderStatusIndicator(String status) {
    List<String> statuses = ['pending', 'preparing', 'ready to pickup', 'completed'];
    int currentIndex = statuses.indexOf(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        int index = statuses.indexOf(status);
        bool isActive = index <= currentIndex;
        bool isCurrent = index == currentIndex;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: isActive
                        ? const Icon(Icons.check, color: Colors.white, size: 16.0)
                        : null,
                  ),
                  if (index < statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 2.0,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                isCurrent ? statuses[index] : "",
                style: TextStyle(
                  color: isCurrent ? Colors.black : Colors.transparent, // Hide text if not current
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),

            ],
          ),
        );
      }).toList(),
    );

  }

String _getStatusMessage(String status) {
  switch (status) {
    case 'pending':
      return 'Your order is pending';
    case 'preparing':
      return 'Your order is being prepared';
    case 'ready to pickup':
      return 'Please pick up your order';
    case 'completed':
      return 'Your order is completed';
    default:
      return '';
  }
}
