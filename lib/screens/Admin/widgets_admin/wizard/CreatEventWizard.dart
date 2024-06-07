import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/WizardScreen.dart';
import 'package:testtapp/widgets/Event_item.dart';

class CreateNewEventWizard extends StatefulWidget {
  static const String screenRoute = 'CreateEventWizard';
  const CreateNewEventWizard({Key? key}) : super(key: key);

  @override
  State<CreateNewEventWizard> createState() => _CreateNewEventWizardState();
}

class _CreateNewEventWizardState extends State<CreateNewEventWizard> {
  late Future<String?> _selectedEventFuture;

  @override
  void initState() {
    super.initState();
    _selectedEventFuture = Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _selectedEventFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر مناسبة',
                  style: StyleTextAdmin(24, AdminButton),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.height * 0.62,
                  height: MediaQuery.of(context).size.height * 0.62,
                  child: EventScreen(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget EventScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('event_types').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final eventDocs = snapshot.data!.docs;
          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 7 / 8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: eventDocs.length,
            itemBuilder: (context, index) {
              final doc = eventDocs[index];
              return EventItemDisplay(
                title: doc['name'].toString(),
                imageUrl: doc['image_url'].toString(),
                id: doc.id,
                onTapFunction: () async {
                  String selectedEvent = doc['name'].toString();
                  // Perform your check here
                  setState(() {
                    _selectedEventFuture = Future.value(selectedEvent);
                  });
                  Navigator.pop(context,
                      selectedEvent); // Close the alert dialog and pass the selected event
                },
              );
            },
          );
        }
      },
    );
  }
}
