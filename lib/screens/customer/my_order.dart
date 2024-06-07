import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/screens/customer/add_feedback.dart';
import 'package:unicafe/screens/customer/view_feedback.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerID', isEqualTo: customer.id)
            .snapshots(),
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
                        _buildOrderStatusIndicator(orderStatus),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8.0),
                        Text('Order ID: ${doc.id}'),
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
                            ),                          /*
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedbackPage(orderId: doc.id),
                                  ),
                                );
                              },
                              child: const Text(
                                'Rate this order',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),*/
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
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
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}