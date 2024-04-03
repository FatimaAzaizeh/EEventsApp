import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/widgets/Event_item.dart';

class EventScreen extends StatefulWidget {
  static const String screenRoute = 'Event_screen';
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Future<List<EventItemDisplay>> eventList;

  @override
  void initState() {
    super.initState();
    eventList = getEventDataFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventItemDisplay>>(
      future: eventList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GridView(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 7 / 8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            children: snapshot.data!
                .map((eventType) => EventItemDisplay(
                      title: eventType.title,
                      imageUrl: eventType.imageUrl,
                      id: eventType.id,
                    ))
                .toList(),
          );
        }
      },
    );
  }
}

Future<List<EventItemDisplay>> getEventDataFromFirebase() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('EventType').get();

    List<EventItemDisplay> eventItems = snapshot.docs.map((doc) {
      return EventItemDisplay(
        title: doc['Name'],
        imageUrl: doc['imageUrl'],
        id: doc.id,
      );
    }).toList();

    return eventItems;
  } catch (error) {
    print('Error fetching events: $error');
    throw error;
  }
}
