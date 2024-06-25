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
  late String _orderStatus;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order.orderStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Date:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text(DateFormat('dd MMMM yyyy \'at\' h:mm:ss a').format(widget.order.orderDate),
              ),
              const SizedBox(height: 20),
              const Text('Order ID:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text('Order ID: ${widget.order.id}'),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: widget.order.getCustomerName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer Name: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          Text(
                            '${snapshot.data}',
                            style: const TextStyle(fontSize: 16.0), // You can adjust the style as needed
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
                        .map((item) => Text(
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
              const SizedBox(height: 20),
              const Text(
                'Order Status:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButton<String>(
                value: _orderStatus,
                onChanged: (newValue) {
                  // Update order status
                  setState(() {
                    _orderStatus = newValue!;
                  });
                  _updateOrderStatus(context, widget.order, newValue!);
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
        ),
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