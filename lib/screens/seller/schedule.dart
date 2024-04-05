import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:unicafe/models/seller.dart';

class ModifyPickupSlotPage extends StatefulWidget {
  final Seller seller;

  const ModifyPickupSlotPage({super.key, required this.seller});

  @override
  _ModifyPickupSlotPageState createState() => _ModifyPickupSlotPageState();
}

class _ModifyPickupSlotPageState extends State<ModifyPickupSlotPage> {
  final _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Times'),
      ),
      body: ListView.builder(
        itemCount: _daysOfWeek.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_daysOfWeek[index]),
              subtitle: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('sellers')
                    .doc(widget.seller.id)
                    .collection('pickupSlots')
                    .doc(_daysOfWeek[index])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null) {
                      var data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null) {

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => _selectTime(context, true, _daysOfWeek[index], data['startTime']),
                              child: Text('Start: ${data['startTime'] ?? 'Not set'}'),
                            ),
                            InkWell(
                              onTap: () => _selectTime(context, false, _daysOfWeek[index], data['endTime']),
                              child: Text('End: ${data['endTime'] ?? 'Not set'}'),
                            ),
                          ],
                        );
                      }
                    }
                  }
                  return const Text('Loading...');
                },
              ),
              onTap: () => _showModifyDialog(context, _daysOfWeek[index]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime, String dayOfWeek, String? currentTime) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 10, minute: 0); // Default time if not set
    if (currentTime != null) {
      // Adjust parsing for AM/PM format
      final dateFormat = DateFormat.jm(); // For parsing the initial time in AM/PM format
      DateTime parsedDate = dateFormat.parse(currentTime);
      initialTime = TimeOfDay(hour: parsedDate.hour, minute: parsedDate.minute);
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      // Convert pickedTime to a DateTime to use with DateFormat
      final now = DateTime.now();
      final pickedDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final newTime = DateFormat.jm().format(pickedDateTime); // Format to AM/PM

      final slotMap = {
        isStartTime ? 'startTime' : 'endTime': newTime,
      };

      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.seller.id)
          .collection('pickupSlots')
          .doc(dayOfWeek)
          .set(slotMap, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pickup time updated successfully!')));

      setState(() {}); // Rebuild the widget to reflect the update
    }
  }

  Future<void> _showModifyDialog(BuildContext context, String dayOfWeek) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modify Time for $dayOfWeek"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _selectTime(context, true, dayOfWeek, null),
                  child: const Text('Set Start Time'),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context, false, dayOfWeek, null),
                  child: const Text('Set End Time'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
