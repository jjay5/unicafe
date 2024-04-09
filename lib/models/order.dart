import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String? id;
  final DateTime orderDate;
  final double totalAmount;
  final String orderStatus;
  final String paymentMethod;
  final String pickupMethod;
  final String pickupTime;
  //final bool paid;

  Order({
    this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.pickupMethod,
    required this.pickupTime
   // this.paid = false,
  });

  // Convert Order object to a map
  Map<String, dynamic> toMap() {
    return {
      'orderDate': Timestamp.fromDate(orderDate),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'pickupMethod': pickupMethod,
      'pickupTime': pickupTime,
      //'paid': paid,
    };
  }

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: data['totalAmount'],
      orderStatus: data['orderStatus'],
      paymentMethod: data['paymentMethod'],
      pickupMethod: data['pickupMethod'],
      pickupTime: data['pickupTime'],
      //paid: data['paid'] ?? false,
    );
  }

  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      totalAmount: map['totalAmount'],
      orderStatus: map['orderStatus'],
      paymentMethod: map['paymentMethod'],
      pickupMethod: map['pickupMethod'],
      pickupTime: map['pickupTime']
      //paid: map['paid'] ?? false,
    );
  }
}
