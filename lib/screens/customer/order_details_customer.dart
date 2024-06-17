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
              const SizedBox(height: 20),
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
                            'Order At: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          Row(
                            children: [
                              Text(sellerInfo['stallName'] ?? 'N/A'),
                              Text(', ${sellerInfo['stallLocation'] ?? 'N/A'}'),
                            ],
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      );
                    }
                  }
                  return const CircularProgressIndicator();
                },
              ),

              const SizedBox(height: 20),
              const Text('Order Summary:',
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
                    children: [
                      ...orderItems.map((item) {
                        return ListTile(
                          leading: item.menuItem.itemPhoto != null && item.menuItem.itemPhoto!.isNotEmpty
                              ? Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(item.menuItem.itemPhoto!),
                              ),
                            ),
                          )
                              : Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage('assets/images/default_image.png'),
                              ),
                            ),
                          ),
                          title: Text(item.itemName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Notes: ${item.notes}'),
                                  Text('RM ${item.totalPrice.toDouble().toStringAsFixed(2)}'),
                                ],
                              ),
                              Text('Quantity: ${item.quantity}'),
                            ],
                          ),
                        );
                      }),
                      const Divider(thickness: 2.0),
                      // Add a summary section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'RM ${orderItems.fold(0.0, (sum, item) => sum + item.totalPrice).toDouble().toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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