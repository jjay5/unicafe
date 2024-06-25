import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicafe/models/cart.dart';
import 'package:unicafe/models/seller.dart';
import 'package:unicafe/models/pickup_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/order.dart';
import 'package:intl/intl.dart';
import 'package:unicafe/screens/customer/list_menu.dart';
import 'package:unicafe/screens/customer/order_success.dart';

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
  String? _selectedOptionPickup;
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
    var format = DateFormat.jm();
    var startTime = format.parse(slot.startTime);
    var endTime = format.parse(slot.endTime);

    _timeSlots.clear();

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

  void _updateItemQuantity(CartItem cartItem, int newQuantity) {
    setState(() {
      final index = _cartItems.indexOf(cartItem);
      if (index != -1) {
        final updatedItem = CartItem(
          item: cartItem.item,
          quantity: newQuantity,
          note: cartItem.note,
          totalItemPrice: newQuantity * cartItem.item.price,
        );
        _cartItems[index] = updatedItem;
      }
    });
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateCartItemQuantity(cartItem.item, cartItem.note, newQuantity);
  }

  String generateOrderID(int orderCounter) {
    return orderCounter.toString().padLeft(3, '0');
  }

  Future<int> fetchAndUpdateOrderCounter() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference counterRef = firestore.collection('counters').doc('orderCounter');

    DocumentSnapshot counterSnapshot = await counterRef.get();

    int orderCounter = counterSnapshot.exists ? (counterSnapshot.data() as Map<String, dynamic>)['value'] ?? 0 : 0;

    orderCounter++;

    await counterRef.set({'value': orderCounter});

    return orderCounter;
  }

  void _confirmOrder(BuildContext context) async {
    try {
      // Get the current user ID
      String customerID = FirebaseAuth.instance.currentUser!.uid;

      // Fetch and update the order counter
      int orderCounter = await fetchAndUpdateOrderCounter();

      // Generate the order ID
      String orderID = generateOrderID(orderCounter);

      // Create a new order object
      Orders order = Orders(
        id: orderID,
        customerID: customerID,
        orderDate: DateTime.now(),
        orderStatus: 'pending',
        totalAmount: _calculateTotal(),
        paymentMethod: _selectedOptionPickup ?? '',
        pickupMethod: _selectedOptionPayment ?? '',
        pickupTime: _selectedTime ?? '',
        sellerID: widget.seller.id,
      );

      // Add the order to the 'orders' collection
      await FirebaseFirestore.instance.collection('orders').doc(orderID).set(order.toMap());

      // Iterate through cart items and add each to the 'orderItems' sub-collection
      for (var cartItem in _cartItems) {
        // Generate a unique ID for each order item based on menuItemId and notes
        String orderItemId = '$orderID${cartItem.item.id}_${cartItem.note}';

        await FirebaseFirestore.instance.collection('orders').doc(orderID).collection('orderItems').doc(orderItemId).set({
          'menuItemId': cartItem.item.id,
          'quantity': cartItem.quantity,
          'totalPrice': cartItem.totalItemPrice,
          'notes': cartItem.note,
          'itemName': cartItem.item.itemName,
        });
      }

      // Navigate to the OrderSuccessPage
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
      );

      Provider.of<CartProvider>(context, listen: false).clearCart();
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
      backgroundColor: Colors.transparent,
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
    if (_cartItems.isEmpty) {
      // If the cart is empty, navigate back to the previous page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Order'),
      ),
      body: _cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('PICKUP AT: ${widget.seller.stallName}, ${widget.seller.stallLocation}'),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PICKUP TIME: $_selectedTime'),
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PICKUP OPTIONS: '),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Dine-in',
                              groupValue: _selectedOptionPickup,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOptionPickup = value;
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
                              groupValue: _selectedOptionPickup,
                              onChanged: (value) {
                                setState(() {
                                  _selectedOptionPickup = value;
                                });
                              },
                            ),
                            const Text('Take-away'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PAYMENT METHOD: '),
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
                                controller: TextEditingController(text: '4242 4242 4242 4242'), // Prefilled card number
                                decoration: const InputDecoration(
                                  labelText: 'Card Number',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: TextEditingController(text: '12/23'), // Prefilled expiration date
                                decoration: const InputDecoration(
                                  labelText: 'Expiration Date (MM/YY)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                                keyboardType: TextInputType.datetime,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: TextEditingController(text: '123'), // Prefilled CVV
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('YOUR ORDER:'),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MenuPage(sellerId: widget.seller.id),
                            ),
                          ),
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
                  Column(
                    children: _cartItems.map((item) {
                      return ListTile(
                        leading: item.item.itemPhoto != null && item.item.itemPhoto!.isNotEmpty
                        ? Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(item.item.itemPhoto!),
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
                        title: Text(item.item.itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RM ${item.totalItemPrice.toDouble().toStringAsFixed(2)}'),
                            //Text('Quantity: ${item.quantity}'),
                            Text('Notes: ${item.note}'),
                            const Text('Quantity:'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      _updateItemQuantity(item, item.quantity - 1);
                                    } else {
                                      _removeItem(_cartItems.indexOf(item));
                                    }
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _updateItemQuantity(item, item.quantity + 1);
                                  },
                                ),
                              ],
                            ),
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
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total: RM${_calculateTotal().toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Adjust text color as needed
              ),
              ElevatedButton(
                child: const Text('Place Order'),
                onPressed: () async {

                  final pickup = _selectedOptionPickup ?? '';
                  final payment = _selectedOptionPayment ?? '';

                  if (pickup.isEmpty && payment.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select the pickup option and payment option.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  if (pickup.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select the pickup option.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  if (payment.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select the payment option.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  try{
                    _confirmOrder(context);
                  } catch (e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Place Order Failed'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}