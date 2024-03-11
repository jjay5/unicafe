class MenuItem {
  String id;
  String name;
  String description;
  double price;
  bool availability;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.availability,
  });

  // Convert a MenuItem instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'availability': availability,
    };
  }

  // Create a MenuItem instance from a map
  static MenuItem fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      availability: map['availability'],
    );
  }
}
