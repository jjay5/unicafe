import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerFeedbackPage extends StatefulWidget {
  final String sellerId;

  const SellerFeedbackPage({super.key, required this.sellerId});

  @override
  SellerFeedbackPageState createState() => SellerFeedbackPageState();
}

class SellerFeedbackPageState extends State<SellerFeedbackPage> {
  Widget _buildStarRating(double rating) {
    int wholePart = rating.floor();
    bool hasHalfStar = (rating - wholePart) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < wholePart) {
          return const Icon(Icons.star, color: Colors.amber);
        } else if (index == wholePart && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _retrieveOrderItems(String orderId) async {
    var orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
    var orderItemsSnapshot = await orderDoc.reference.collection('orderItems').get();
    Map<String, Map<String, dynamic>> itemSummary = {};

    for (var orderItemDoc in orderItemsSnapshot.docs) {
      var itemName = orderItemDoc.data()['itemName'];
      var quantity = orderItemDoc.data()['quantity'];
      var note = orderItemDoc.data()['note'] ?? "";

      String key = "$itemName$note"; // Combine item name and note as a key for uniqueness
      if (!itemSummary.containsKey(key)) {
        itemSummary[key] = {
          'itemName': itemName,
          'quantity': 0,
          'note': note,
        };
      }
      itemSummary[key]!['quantity'] += quantity;
    }
    return itemSummary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedback'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerID', isEqualTo: widget.sellerId)
            .snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderSnapshot.hasError) {
            return Center(child: Text('Error: ${orderSnapshot.error}'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collectionGroup('feedback').snapshots(),
            builder: (context, feedbackSnapshot) {
              if (feedbackSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (feedbackSnapshot.hasError) {
                return Center(child: Text('Error: ${feedbackSnapshot.error}'));
              }

              List<QueryDocumentSnapshot> sellerFeedback = feedbackSnapshot.data!.docs.where((feedbackDoc) {
                return orderSnapshot.data!.docs.any((orderDoc) =>
                orderDoc.id == feedbackDoc.reference.parent.parent!.id &&
                    orderDoc['sellerID'] == widget.sellerId);
              }).toList();

              if (sellerFeedback.isEmpty) {
                return const Center(child: Text('No feedback available.'));
              }

              return ListView.builder(
                itemCount: sellerFeedback.length,
                itemBuilder: (context, index) {
                  var feedbackDoc = sellerFeedback[index];
                  String orderId = feedbackDoc.reference.parent.parent!.id;
                  return FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: _retrieveOrderItems(orderId),
                    builder: (context, orderItemsSnapshot) {
                      if (orderItemsSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Order ID: $orderId'),
                          subtitle: const Text('Loading item details...'),
                        );
                      }
                      if (orderItemsSnapshot.hasError) {
                        return ListTile(
                          title: Text('Order ID: $orderId'),
                          subtitle: Text('Error: ${orderItemsSnapshot.error}'),
                        );
                      }

                      List<String> itemDetails = orderItemsSnapshot.data!.values.map((item) {
                        String notePart = item['note'].isNotEmpty ? " (Notes: ${item['note']})" : "";
                        return "${item['itemName']} x ${item['quantity']}$notePart";
                      }).toList();

                      return ListTile(
                        title: Text('Order ID: $orderId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStarRating(feedbackDoc['rating'].toDouble()),
                            Text('Comment: ${feedbackDoc['comment']}'),
                            Text('Ordered: ${itemDetails.join(", ")}'),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}