class PickupSlot {
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  PickupSlot({required this.dayOfWeek, required this.startTime, required this.endTime});

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory PickupSlot.fromMap(Map<String, dynamic> map) {
    return PickupSlot(
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}
