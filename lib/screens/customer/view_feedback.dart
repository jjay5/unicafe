import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFeedbackPage extends StatelessWidget {
  final String orderId;

  const ViewFeedbackPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedback'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('feedback')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No feedback found.'));
          }

          DocumentSnapshot feedbackDoc = snapshot.data!.docs.first;
          Map<String, dynamic> feedbackData = feedbackDoc.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStarRating(feedbackData['rating']?.toDouble() ?? 0.0),
                const SizedBox(height: 8.0),
                Text(
                  'Comment: ${feedbackData['comment']}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Submitted on: ${feedbackData['timestamp'].toDate()}',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
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