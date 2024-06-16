import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unicafe/models/order.dart';

class OrderDetailPage extends StatefulWidget {
  final Orders order;

  const OrderDetailPage({super.key, required this.order});

  @override
  OrderDetailPageState createState() => OrderDetailPageState();
}

class OrderDetailPageState extends State<OrderDetailPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Date:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text(DateFormat('dd MMMM yyyy \'at\' h:mm:ss a').format(
                  widget.order.orderDate),
              ),
              const SizedBox(height: 20),
              const Text('Order ID:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text('Order ID: ${widget.order.id}'),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, String>>(
                future: widget.order.getSellerInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final sellerInfo = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seller Stall Name: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          Text(
                            sellerInfo['stallName'] ?? 'N/A',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Stall Location: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          Text(
                            sellerInfo['stallLocation'] ?? 'N/A',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      );
                    }
                  }

                  return const CircularProgressIndicator();
                },
              ),

              const SizedBox(height: 20),
              const Text('Items:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              StreamBuilder<List<OrderItem>>(
                stream: widget.order.getOrderItems(),
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
                        .map((item) =>
                        Text(
                          '${item.quantity}x ${item.itemName} \n ${item.notes}',
                        ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Payment Method:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              Text(widget.order.paymentMethod),
              const SizedBox(height: 20),
              const Text('Pickup Method:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              Text(widget.order.pickupMethod),
              const SizedBox(height: 20),
              const Text('Pick Up Time:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              Text(widget.order.pickupTime),

              const SizedBox(height: 20),
              const Text(
                'Order Status:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(widget.order.orderStatus),

            ],
          ),
        ),
      ),
    );
  }
}