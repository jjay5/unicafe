import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/models/pickup_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/order.dart';
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Seller seller;
  final List<CartItem> cartItems;

  const OrderConfirmationPage({
    super.key,
    required this.seller,
    required this.cartItems,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  late List<CartItem> _cartItems;
  String? _selectedTime;
  final List<String> _timeSlots = [];
  String? _selectedOption;
  String? _selectedOptionPayment;
  bool _showCardDetails = false; // Initially hidden

  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartItems;
    _fetchAvailableSlots();
  }

  void _fetchAvailableSlots() async {
    var now = DateTime.now();
    var formatter = DateFormat('EEEE');
    String dayOfWeek = formatter.format(now);

    var slotDocument = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.seller.id)
        .collection('pickupSlots')
        .doc(dayOfWeek)
        .get();

    if (slotDocument.exists) {
      PickupSlot slot = PickupSlot.fromMap(slotDocument.data()!, slotDocument.id);
      _generateTimeSlots(slot);
    }
  }

  void _generateTimeSlots(PickupSlot slot) {
    var format = DateFormat.jm(); // For easier reuse
    var startTime = format.parse(slot.startTime);
    var endTime = format.parse(slot.endTime);

    _timeSlots.clear(); // Clear previous slots, if any

    while (startTime.add(const Duration(hours: 1)).isBefore(endTime)) {
      var nextTime = startTime.add(const Duration(hours: 1));
      _timeSlots.add('${format.format(startTime)} - ${format.format(nextTime)}');
      startTime = nextTime;
    }

    // Check if there is remaining time for a shorter slot
    if (startTime.isBefore(endTime)) {
      // Add the last time slot that may not be a full hour
      _timeSlots.add('${format.format(startTime)} - ${format.format(endTime)}');
    }

    // Set default selected time as the first slot if available
    if (_timeSlots.isNotEmpty) {
      _selectedTime = _timeSlots.first;
    }
    setState(() {});
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (total, current) => total + (current.item.price * current.quantity));
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    // Update the cart provider to remove the item
    Provider.of<CartProvider>(context, listen: false).removeCartItem(index);
  }

  void _confirmOrder(BuildContext context) async {
    try {
      // Get the current user ID
      String customerID = FirebaseAuth.instance.currentUser!.uid;

      // Create a new order object
      Orders order = Orders(
        id: null,
        customerID: customerID,
        orderDate: DateTime.now(),
        orderStatus: 'pending',
        totalAmount: _calculateTotal(),
        paymentMethod: _selectedOption ?? '',
        pickupMethod: _selectedOptionPayment ?? '',
        pickupTime: _selectedTime ?? '',
        items: _cartItems,
        sellerID: widget.seller.id,
        //items: _cartItems, // Use the cart items directly
      );

      // Reference to Firestore
      final firestore = FirebaseFirestore.instance;

      // Add the order to the 'orders' collection
      DocumentReference orderRef =
      await firestore.collection('orders').add(order.toMap());

      // Iterate through cart items and add each to the 'orderItems' sub-collection
      for (var cartItem in _cartItems) {
        await orderRef.collection('orderItems').add({
          'menuItemId': cartItem.item.id, // Adjust according to your item model
          'quantity': cartItem.quantity,
          'totalPrice': cartItem.totalItemPrice,
          'notes': cartItem.note,
          // Add more fields as necessary
        });
      }

      // Show a success message or navigate to a success page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Optionally, clear the cart after order is placed
      //Provider.of<CartProvider>(context, listen: false).clearCart();
    } catch (e) {
      // Handle errors (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  void _showPickupTimeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Makes the background transparent
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Pickup Time',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Apply the Scrollbar to the ListView.builder only
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true, // Always show the scrollbar thumb
                  child: ListView.builder(
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_timeSlots[index]),
                        onTap: () {
                          setState(() {
                            _selectedTime = _timeSlots[index];
                          });
                          Navigator.pop(context); // Close the modal
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Order'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Pickup at: ${widget.seller.stallName}, ${widget.seller.stallLocation}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pickup time: $_selectedTime'),
                        InkWell(
                          onTap: () => _showPickupTimeSelection(context),
                          child: const Text(
                            'EDIT',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Option form section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pickup Options: '),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Dine-in',
                              groupValue: _selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOption = value;
                                });
                              },
                            ),
                            const Text('Dine-in'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Take-away',
                              groupValue: _selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOption = value;
                                });
                              },
                            ),
                            const Text('Take-away'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment method: '),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Cash',
                              groupValue: _selectedOptionPayment,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOptionPayment = value;
                                  _showCardDetails = false;
                                });
                              },
                            ),
                            const Text('Cash'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Card',
                              groupValue: _selectedOptionPayment,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOptionPayment = value;
                                  _showCardDetails = value == 'Card'; // Show card details if 'Online' is selected
                                });
                              },
                            ),


                            const Text('Card'),
                          ],
                        ),
                        if (_showCardDetails)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0), // Add some vertical padding
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Card Number',
                                    border: OutlineInputBorder(), // Adds a border around the input field
                                    contentPadding: EdgeInsets.all(10), // Adds padding inside the input field
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8), // Adds space between input fields
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Expiration Date (MM/YY)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your Order:'),
                        InkWell(
                          onTap: () => _showPickupTimeSelection(context),
                          child: const Text(
                            'ADD ITEMS',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Alternative to ListView.builder
                  Column(
                    children: _cartItems.map((item) {
                      return ListTile(
                        title: Text(item.item.itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //('RM ${(item.quantity * item.item.price).toDouble().toStringAsFixed(2)}'),
                            Text('RM ${item.totalItemPrice.toDouble().toStringAsFixed(2)}'),
                            Text('Quantity: ${item.quantity}'),
                            Text('Notes: ${item.note}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            _removeItem(_cartItems.indexOf(item));
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey, // Set the desired color for the bottom navigation bar
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total: RM${_calculateTotal().toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, color: Colors.white), // Adjust text color as needed
              ),
              ElevatedButton(
                onPressed: () => _confirmOrder(context),
                child: const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
