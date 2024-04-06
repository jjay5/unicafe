import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/models/pickup_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _confirmOrder(BuildContext context) {
    // Handle the order confirmation logic here
    if (kDebugMode) {
      print("ss: $_selectedTime");
    }
    if (kDebugMode) {
      print("$_selectedOption");
    }
    if (kDebugMode) {
      print("$_selectedOptionPayment");
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
                        });
                      },
                    ),
                    const Text('Cash'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Online',
                      groupValue: _selectedOptionPayment,
                      onChanged: (value) {
                        setState(() {
                          _selectedOptionPayment = value;
                        });
                      },
                    ),
                    const Text('Online'),
                  ],
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
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                CartItem item = _cartItems[index];
                return ListTile(
                  title: Text(item.item.itemName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${item.quantity}'),
                      Text('Notes: ${item.note}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      _removeItem(index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Total: RM${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () => _confirmOrder(context),
                  child: const Text('Place Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}