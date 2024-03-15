import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicafe/models/pickup_slot.dart'; // Adjust the import based on your project structure

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({super.key});

  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  List<PickupSlot> _slots = [];
  String _selectedDayOfWeek = 'Monday';
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  Future<void> _showTimePicker(BuildContext context, bool isStartTime) async {
    final initialTime = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime ?? initialTime : _selectedEndTime ?? initialTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = pickedTime;
        } else {
          _selectedEndTime = pickedTime;
        }
      });
    }
  }

  void _addSlot() {
    if (_selectedStartTime != null && _selectedEndTime != null) {
      final slot = PickupSlot(
        dayOfWeek: _selectedDayOfWeek,
        startTime: _selectedStartTime!.format(context),
        endTime: _selectedEndTime!.format(context),
      );
      setState(() {
        _slots.add(slot);
      });
    }
  }

  void _saveSlots() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      for (final slot in _slots) {
        await FirebaseFirestore.instance.collection('pickupSlots').add(slot.toMap());
      }
      // Show confirmation and clear form or navigate away
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Pickup Schedule')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedDayOfWeek,
              onChanged: (value) => setState(() => _selectedDayOfWeek = value!),
              items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Row(
              children: <Widget>[
                Text('Start Time: ${_selectedStartTime?.format(context) ?? ''}'),
                ElevatedButton(
                  onPressed: () => _showTimePicker(context, true),
                  child: Text('Pick Start Time'),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('End Time: ${_selectedEndTime?.format(context) ?? ''}'),
                ElevatedButton(
                  onPressed: () => _showTimePicker(context, false),
                  child: Text('Pick End Time'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addSlot,
              child: Text('Add Slot'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  return ListTile(
                    title: Text('${slot.dayOfWeek}: ${slot.startTime} - ${slot.endTime}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveSlots,
              child: Text('Save Slots'),
            ),
          ],
        ),
      ),
    );
  }
}
