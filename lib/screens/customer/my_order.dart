import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/customer.dart';
import 'package:unicafe/screens/customer/add_feedback.dart';



class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final customer = customerProvider.customer;

    if (customer == null) {
      return Scaffold(
        body: Center(
          child: Text("No customer signed in"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerID', isEqualTo: customer.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              // Optionally, fetch customer name from Firestore if needed
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('sellers').doc(data['sellerID']).get(),
                builder: (context, sellerSnapshot) {
                  if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Order ID: ${doc.id}'),
                      subtitle: Text('Loading customer details...'),
                    );
                  }
                  if (sellerSnapshot.hasError) {
                    return ListTile(
                      title: Text('Order ID: ${doc.id}'),
                      subtitle: Text('Error loading customer details'),
                    );
                  }
                  if (!sellerSnapshot.hasData) {
                    return ListTile(
                      title: Text('Order ID: ${doc.id}'),
                      subtitle: Text('Customer details not found'),
                    );
                  }
                  Map<String, dynamic> sellerData = sellerSnapshot.data!.data() as Map<String, dynamic>;
                  //String fetchedCustomerName = customerData['email'];

                  String orderStatusMessage = _getStatusMessage(data['orderStatus']);
                  bool isCompleted = data['orderStatus'] == 'completed'; // Check if order status is completed

                  return Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderStatusMessage,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        Divider(color: Colors.grey), // This adds a horizontal line after the title
                        SizedBox(height: 8.0), // Additional spacing after the divider if needed
                        Text('Order ID: ${doc.id}'),
                        Text(
                          'Order Date: ${DateFormat('MMMM dd, yyyy \'at\' h:mm:ss a').format(data['orderDate'].toDate())}',
                        ),
                        SizedBox(height: 8.0),
                        Row(
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
                        if (isCompleted) // Conditionally add the hyperlink if order status is completed

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {// Navigate to MenuPage with selected seller's ID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedbackPage(orderId: doc.id),
                                  ),
                                );
                              },
                              child: Text(
                                'Rate this order',
                                style: TextStyle(
                                  color: Colors.blue, // Change the color to match your design
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
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
  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order is pending';
      case 'preparing':
        return 'Preparing your order';
      case 'ready to pickup':
        return 'Please pick up your order';
      case 'completed':
        return 'Order has been completed';
      default:
        return 'Status: $status'; // Default case for other statuses
    }
  }
}

