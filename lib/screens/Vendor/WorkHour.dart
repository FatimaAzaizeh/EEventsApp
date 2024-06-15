import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';

class OpeningHoursPage extends StatefulWidget {
  @override
  _OpeningHoursPageState createState() => _OpeningHoursPageState();
}

class _OpeningHoursPageState extends State<OpeningHoursPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, TimeOfDay?> openingHours = {};
  Map<String, TimeOfDay?> closingHours = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchOpeningHours();
  }

  Future<void> _fetchOpeningHours() async {
    try {
      final doc = await _firestore
          .collection('vendor')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('working_hours')) {
          final Map<String, dynamic> workingHours = data['working_hours'];

          for (var day in workingHours.keys) {
            openingHours[day] = _convertTimestampToTimeOfDay(
                workingHours[day]['working_hour_from']);
            closingHours[day] = _convertTimestampToTimeOfDay(
                workingHours[day]['working_hour_to']);
          }
        }
      }

      setState(() {}); // Refresh UI with fetched data
    } catch (error) {
      print('Error fetching opening hours: $error');
    }
  }

  TimeOfDay? _convertTimestampToTimeOfDay(Timestamp? timestamp) {
    if (timestamp == null) return null;
    final dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'الأحد';
      case 1:
        return 'الإثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الإربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      default:
        return '';
    }
  }

  Future<void> _selectOpeningTime(BuildContext context, String day) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: openingHours[day] ?? TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        openingHours[day] = selectedTime;
      });
    }
  }

  Future<void> _selectClosingTime(BuildContext context, String day) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: closingHours[day] ?? TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        closingHours[day] = selectedTime;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$minute: $hour $period';
  }

  void _saveOpeningHours() {
    setState(() {
      _saving = true;
    });

    final workingHoursMap = <String, Map<String, dynamic>>{};

    openingHours.forEach((day, time) {
      if (time != null && closingHours[day] != null) {
        workingHoursMap[day] = {
          'working_hour_from': _getTimestamp(time),
          'working_hour_to': _getTimestamp(closingHours[day]!),
        };
      }
    });

    _firestore.collection('vendor').doc(_auth.currentUser!.uid).update({
      'working_hours': workingHoursMap,
    }).then((_) {
      print('Opening hours saved successfully!');
      SuccessAlert(context, "تم حفظ ساعات العمل بنجاح!");
    }).catchError((error) {
      ErrorAlert(context, 'خطأ', 'فشل حفظ ساعات العمل.');
    }).whenComplete(() {
      setState(() {
        _saving = false;
      });
    });
  }

  Timestamp _getTimestamp(TimeOfDay time) {
    final now = DateTime.now();
    final timestamp = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return Timestamp.fromDate(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorCream_50,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saving ? null : _saveOpeningHours,
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
          _saving
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(165, 255, 255, 255)
                            .withOpacity(0.3),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(6, 255, 255, 255)
                          .withOpacity(0.22),
                    ),
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(3),
                      },
                      border: TableBorder.all(
                          color: ColorPink_50,
                          width: 3,
                          borderRadius: BorderRadius.circular(10)),
                      children: [
                        for (int i = 0; i < 7; i++)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _getDayOfWeek(i),
                                  style: StyleTextAdmin(16, Colors.black),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () => _selectOpeningTime(
                                      context, _getDayOfWeek(i)),
                                  child: Text(
                                    'يفتح: ${_formatTime(openingHours[_getDayOfWeek(i)])}',
                                    style: StyleTextAdmin(14, AdminButton),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () => _selectClosingTime(
                                      context, _getDayOfWeek(i)),
                                  child: Text(
                                    'يغلق: ${_formatTime(closingHours[_getDayOfWeek(i)])}',
                                    style: StyleTextAdmin(14, AdminButton),
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
}
