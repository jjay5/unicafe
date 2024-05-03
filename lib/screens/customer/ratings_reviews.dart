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

      // Retrieve order items
      var orderItemsSnapshot = await orderDoc.reference.collection('orderItems').get();
      Map<String, Map<String, dynamic>> itemsSummary = {}; // Use a map to collect item summaries
      for (var orderItemDoc in orderItemsSnapshot.docs) {
        var menuItemId = orderItemDoc.data()['menuItemId'];
        var quantity = orderItemDoc.data()['quantity'];
        var note = orderItemDoc.data()['note'] ?? ""; // Assume there is a 'note' field you want to track

        // Fetch the itemName from the menuItems collection using menuItemId
        var menuItemDoc = await FirebaseFirestore.instance.collection('menuItems').doc(menuItemId).get();
        if (menuItemDoc.exists) {
          var itemName = menuItemDoc.data()!['itemName'];
          // Check if item already added to the summary
          if (!itemsSummary.containsKey(menuItemId)) {
            itemsSummary[menuItemId] = {
              'name': itemName,
              'totalQuantity': 0,
              'notes': []
            };
          }
          itemsSummary[menuItemId]?['totalQuantity'] += quantity;
          if (note.isNotEmpty) {
            itemsSummary[menuItemId]?['notes'].add(note);
          }
        }
      }

      // Format order items to string list
      List<String> orderItems = itemsSummary.values.map((item) {
        var notesString = item['notes'].isEmpty ? "" : " (Notes: ${item['notes'].join(', ')})";
        return "${item['name']} x ${item['totalQuantity']}$notesString";
      }).toList();

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
        title: Text('Ratings and Reviews'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reviews found'));
          }
          return ListView(
            children: snapshot.data!.map((review) {
              return ListTile(
                title: Text('${review['customerName']}',
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
    int wholePart = rating.floor(); // Get the whole part of the rating
    bool hasHalfStar = (rating - wholePart) >= 0.5; // Check for half star
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < wholePart) {
          return Icon(Icons.star, color: Colors.amber); // Full star for whole parts
        } else if (index == wholePart && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.amber); // Half star
        } else {
          return Icon(Icons.star_border, color: Colors.amber); // Empty star
        }
      }),
    );
  }
}
