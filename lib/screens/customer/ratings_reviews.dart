import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsAndReviewsPage extends StatelessWidget {
  final String sellerId;

  const RatingsAndReviewsPage({super.key, required this.sellerId});

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    var ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerID', isEqualTo: sellerId)
        .get();

    List<Map<String, dynamic>> reviews = [];
    for (var orderDoc in ordersSnapshot.docs) {
      var feedbackSnapshot = await orderDoc.reference.collection('feedback').get();
      var customerSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(orderDoc.data()['customerID'])
          .get();
      String customerName = customerSnapshot.exists ? customerSnapshot.data()!['name'] : 'Unknown Customer';

      // Retrieve order items directly using stored item names and aggregate them by name and notes
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
        itemSummary[key]?['quantity'] += quantity;
      }

      List<String> orderItems = itemSummary.values.map((item) {
        String notePart = item['note'].isNotEmpty ? " (Notes: ${item['note']})" : "";
        return "${item['itemName']} x ${item['quantity']}$notePart";
      }).toList();

      // Collect feedback with associated customer name and formatted order items
      for (var feedbackDoc in feedbackSnapshot.docs) {
        var feedbackData = feedbackDoc.data();
        feedbackData['customerName'] = customerName;
        feedbackData['orderItems'] = orderItems.join(", "); // Format order items as a comma-separated string

        reviews.add(feedbackData);
      }
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings and Reviews'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reviews found'));
          }
          return ListView(
            children: snapshot.data!.map((review) {
              return ListTile(
                title: Text(review['customerName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStarRating(review['rating']?.toDouble() ?? 0.0),

                    Text(review['comment'] ?? 'No content'),
                    const SizedBox(height: 8),
                    Text('Ordered: ${review['orderItems']}'),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

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
}