import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/menu_item.dart';

class Orders {
  final String? id;
  final String customerID;
  final String sellerID;
  final DateTime orderDate;
  final double totalAmount;
  final String orderStatus;
  final String paymentMethod;
  final String pickupMethod;
  final String pickupTime;

  Orders({
    this.id,
    required this.customerID,
    required this.sellerID,
    required this.orderDate,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.pickupMethod,
    required this.pickupTime,
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
      'customerID': customerID,
      'sellerID': sellerID,
    };
  }

  // Factory method to create Orders object from Firestore snapshot
  factory Orders.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Orders(
      id: doc.id,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: data['totalAmount'],
      orderStatus: data['orderStatus'],
      paymentMethod: data['paymentMethod'],
      pickupMethod: data['pickupMethod'],
      pickupTime: data['pickupTime'],
      customerID: data['customerID'],
      sellerID: data['sellerID'],
    );
  }

  // Method to update order status
  Future<void> updateOrderStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(id)
        .update({'orderStatus': newStatus});
  }

  // Method to get order items
  Stream<List<OrderItem>> getOrderItems() {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(id)
        .collection('orderItems')
        .snapshots()
        .asyncMap((snapshot) async {
      List<OrderItem> orderItems = [];
      for (DocumentSnapshot doc in snapshot.docs) {
        // Cast doc.data() to Map<String, dynamic> safely
        var data = doc.data();
        if (data is Map<String, dynamic>) {
          String? menuItemId = data['menuItemId'];
          if (menuItemId != null) {
            // Fetch the menuItem using the menuItemId
            DocumentSnapshot menuItemDoc = await FirebaseFirestore.instance
                .collection('menuItems')
                .doc(menuItemId)
                .get();
            // Assume that menuItemDoc exists and contains correct data
            MenuItem menuItem = MenuItem.fromFirestore(menuItemDoc);
            OrderItem orderItem = OrderItem.fromFirestore(doc, menuItem);
            orderItems.add(orderItem);
          } else {
            // Handle the case where menuItemId is null
            // E.g., log an error or skip this particular OrderItem
          }
        } else {
          // Handle the case where data is not a map
          // This might involve logging or throwing an error
        }
      }
      return orderItems;
    });
  }
}

// Model class for order items
class OrderItem {
  final String menuItemId;
  final int quantity;
  final double totalPrice;
  final String notes;
  final MenuItem menuItem;// Include MenuItem object
  final String itemName;// Use this for feedback, if seller delete the menu item it still can display the item name

  OrderItem({
    required this.menuItemId,
    required this.quantity,
    required this.totalPrice,
    required this.notes,
    required this.menuItem, // Require MenuItem object

    required this.itemName,
  });

  // Factory method to create OrderItem object from Firestore snapshot
  factory OrderItem.fromFirestore(DocumentSnapshot doc, MenuItem menuItem) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return OrderItem(
      menuItemId: data['menuItemId'],
      quantity: data['quantity'],
      totalPrice: data['totalPrice'],
      notes: data['notes'],
      menuItem: menuItem, // Pass MenuItem object
      itemName: data['itemName'],
    );
  }
}