class PickupSlot {
  String sellerId;
  String dayOfWeek;
  String startTime;
  String endTime;

  PickupSlot({
    required this.sellerId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory PickupSlot.fromMap(Map<String, dynamic> map, String id) {
    return PickupSlot(
      sellerId: map['sellerId'],
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}