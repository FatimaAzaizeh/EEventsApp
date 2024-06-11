import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/Admin_screen.dart';

class OpeningHoursPage extends StatefulWidget {
  @override
  _OpeningHoursPageState createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends State<OpeningHoursPage> {
  final _auth = FirebaseAuth.instance;
  Map<String, TimeOfDay> openingHours = {
    'Monday': TimeOfDay(hour: 9, minute: 0),
    'Tuesday': TimeOfDay(hour: 9, minute: 0),
    'Wednesday': TimeOfDay(hour: 9, minute: 0),
    'Thursday': TimeOfDay(hour: 9, minute: 0),
    'Friday': TimeOfDay(hour: 9, minute: 0),
    'Saturday': TimeOfDay(hour: 9, minute: 0),
    'Sunday': TimeOfDay(hour: 9, minute: 0),
  };

  Map<String, TimeOfDay> closingHours = {
    'Monday': TimeOfDay(hour: 17, minute: 0),
    'Tuesday': TimeOfDay(hour: 17, minute: 0),
    'Wednesday': TimeOfDay(hour: 17, minute: 0),
    'Thursday': TimeOfDay(hour: 17, minute: 0),
    'Friday': TimeOfDay(hour: 17, minute: 0),
    'Saturday': TimeOfDay(hour: 17, minute: 0),
    'Sunday': TimeOfDay(hour: 17, minute: 0),
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorCream_50,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOpeningHours,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/signin.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                },
                border: TableBorder.all(color: Color.fromARGB(216, 239, 237, 237)),
                children: [
                  for (int i = 0; i < 7; i++)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_getDayOfWeek(i)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () =>
                                _selectOpeningTime(context, _getDayOfWeek(i)),
                            child: Text(
                              'Open: ${_formatTime(openingHours[_getDayOfWeek(i)]!)}',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () =>
                                _selectClosingTime(context, _getDayOfWeek(i)),
                            child: Text(
                              'Close: ${_formatTime(closingHours[_getDayOfWeek(i)]!)}',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
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

    _firestore.collection('vendor').doc(_auth.currentUser!.uid).update({
      'working_hours': workingHoursMap,
    }).then((_) {
      print('Opening hours saved successfully!');

      SuccessAlert(context,"تم حفظ ساعات العمل بنجاح!");

     
      
    }).catchError((error) {
      ErrorAlert(context, 'خطأ', 'فشل حفظ ساعات العمل.');
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


