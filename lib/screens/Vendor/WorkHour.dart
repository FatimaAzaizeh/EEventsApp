import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/screens/Admin/Admin_screen.dart';

class OpeningHoursPage extends StatefulWidget {
  @override
  _OpeningHoursPageState createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends State<OpeningHoursPage> {
  final _auth = FirebaseAuth.instance;
  Map<String, TimeOfDay> openingHours = {
    'Monday': TimeOfDay(hour: 9, minute: 0), // Default opening time for Monday
    'Tuesday':
        TimeOfDay(hour: 9, minute: 0), // Default opening time for Tuesday
    'Wednesday':
        TimeOfDay(hour: 9, minute: 0), // Default opening time for Wednesday
    'Thursday':
        TimeOfDay(hour: 9, minute: 0), // Default opening time for Thursday
    'Friday': TimeOfDay(hour: 9, minute: 0), // Default opening time for Friday
    'Saturday':
        TimeOfDay(hour: 9, minute: 0), // Default opening time for Saturday
    'Sunday': TimeOfDay(hour: 9, minute: 0), // Default opening time for Sunday
  };

  Map<String, TimeOfDay> closingHours = {
    'Monday': TimeOfDay(hour: 17, minute: 0), // Default closing time for Monday
    'Tuesday':
        TimeOfDay(hour: 17, minute: 0), // Default closing time for Tuesday
    'Wednesday':
        TimeOfDay(hour: 17, minute: 0), // Default closing time for Wednesday
    'Thursday':
        TimeOfDay(hour: 17, minute: 0), // Default closing time for Thursday
    'Friday': TimeOfDay(hour: 17, minute: 0), // Default closing time for Friday
    'Saturday':
        TimeOfDay(hour: 17, minute: 0), // Default closing time for Saturday
    'Sunday': TimeOfDay(hour: 17, minute: 0), // Default closing time for Sunday
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opening Hours'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOpeningHours,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          String day = _getDayOfWeek(index);
          return ListTile(
            title: Text(day),
            subtitle: Row(
              children: [
                TextButton(
                  onPressed: () => _selectOpeningTime(context, day),
                  child: Text(
                    'Open: ${_formatTime(openingHours[day]!)}',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () => _selectClosingTime(context, day),
                  child: Text(
                    'Close: ${_formatTime(closingHours[day]!)}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return '';
    }
  }

  Future<void> _selectOpeningTime(BuildContext context, String day) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: openingHours[day]!,
    );
    if (selectedTime != null) {
      setState(() {
        openingHours[day] = selectedTime;
      });
    }
  }

  Future<void> _selectClosingTime(BuildContext context, String day) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: closingHours[day]!,
    );
    if (selectedTime != null) {
      setState(() {
        closingHours[day] = selectedTime;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _saveOpeningHours() {
    Map<String, Map<String, dynamic>> workingHoursMap = {};

    openingHours.forEach((day, time) {
      workingHoursMap[day] = {
        'working_hour_from': _getTimestamp(time),
        'working_hour_to': _getTimestamp(closingHours[day]!),
      };
    });

    // Save to Firestore
    _firestore.collection('vendor').doc(_auth.currentUser!.uid).update({
      'working_hours': workingHoursMap,
    }).then((_) {
      print('Opening hours saved successfully!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Opening hours saved successfully!'),
        duration: Duration(seconds: 2),
      ));
    }).catchError((error) {
      print('Failed to save opening hours: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save opening hours'),
        duration: Duration(seconds: 2),
      ));
    });
  }

  Timestamp _getTimestamp(TimeOfDay time) {
    final DateTime now = DateTime.now();
    final DateTime timestamp = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return Timestamp.fromDate(timestamp);
  }
}

void main() {
  runApp(MaterialApp(
    home: OpeningHoursPage(),
  ));
}
