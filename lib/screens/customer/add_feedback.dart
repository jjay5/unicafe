import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  final String orderId;

  const FeedbackPage({super.key, required this.orderId});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0.0;
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate your order:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildRatingBar(),
            const SizedBox(height: 16.0),
            const Text(
              'Order Items:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: _buildOrderItems(),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Comments:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildCommentField(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
        );
      }),
    );
  }

  Widget _buildOrderItems() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .collection('orderItems')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No order items found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;

            // Retrieve menuItemId from orderItem
            String menuItemId = itemData['menuItemId'];

            // Retrieve itemName from menuItemId in menuItems collection
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('menuItems').doc(menuItemId).get(),
              builder: (context, itemSnapshot) {
                if (itemSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: const Text('Loading item name...'),
                    subtitle: Text('Quantity: ${itemData['quantity']}'),
                  );
                }
                if (itemSnapshot.hasError) {
                  return ListTile(
                    title: const Text('Error loading item name'),
                    subtitle: Text('Quantity: ${itemData['quantity']}'),
                  );
                }
                if (!itemSnapshot.hasData) {
                  return ListTile(
                    title: const Text('Item name not found'),
                    subtitle: Text('Quantity: ${itemData['quantity']}'),
                  );
                }
                String itemName = itemSnapshot.data!['itemName'];

                // Return ListTile with itemName and other details
                return ListTile(
                  title: Text(itemName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${itemData['quantity']}'),
                      // Additional lines can be added here:
                      Text('Notes: ${itemData['notes'] ?? 'N/A'}'),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCommentField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _comment = value;
        });
      },
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: 'Add your comment...',
        border: OutlineInputBorder(),
      ),
    );
  }

  void submitFeedback() async {
    try {
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId);

      await orderRef.collection('feedback').add({
        'rating': _rating,
        'comment': _comment,
        'timestamp': FieldValue.serverTimestamp(), // Adds a server-side timestamp
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );

      // Optionally, navigate back or clear fields
      setState(() {
        _rating = 0.0;
        _comment = '';
      });
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e')),
      );
    }
  }
}