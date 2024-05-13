import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AlertAddClass.dart';

import 'package:testtapp/widgets/Event_item.dart';

class EventClassification extends StatefulWidget {
  static const String screenRoute = 'EventClassification';
  const EventClassification({Key? key}) : super(key: key);

  @override
  State<EventClassification> createState() => _EventClassificationState();
}

class _EventClassificationState extends State<EventClassification> {
  late DocumentReference eventTypeRef;
  late Widget _currentMainSection;

  @override
  void initState() {
    super.initState();
    eventTypeRef = FirebaseFirestore.instance
        .collection('event_classificaion_types')
        .doc('2');
    _currentMainSection = MainSectionContainer(
      typeEvent: eventTypeRef,
    );
  }

  void _changeMainSection(DocumentReference newTypeEvent) {
    setState(() {
      eventTypeRef = newTypeEvent;
      _currentMainSection = MainSectionContainer(
        typeEvent: eventTypeRef,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ColorPink_100, // Text color of the button
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddClassification(),
              );
            },
            child: Text(
              'إضافة تصنيف جديد',
              style: StyleTextAdmin(18, Colors.white),
            )),
        ClassificationTypes(changeMainSection: _changeMainSection),
        Expanded(
          flex: 2,
          child: _currentMainSection,
        ),
      ],
    );
  }
}

class ClassificationTypes extends StatefulWidget {
  final void Function(DocumentReference) changeMainSection;
  const ClassificationTypes({Key? key, required this.changeMainSection})
      : super(key: key);

  @override
  State<ClassificationTypes> createState() => _ClassificationTypesState();
}

class _ClassificationTypesState extends State<ClassificationTypes> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('event_classificaion_types')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final classificationTypes = snapshot.data?.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList() ??
                [];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: classificationTypes.map((classificationData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                child: TextButton(
                                  onPressed: () async {
                                    QuerySnapshot querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection(
                                                'event_classificaion_types')
                                            .where('description',
                                                isEqualTo: classificationData[
                                                    'description'])
                                            .get();

                                    for (QueryDocumentSnapshot document
                                        in querySnapshot.docs) {
                                      String documentId = document.id;
                                      DocumentReference eventTypeRef =
                                          FirebaseFirestore.instance
                                              .collection(
                                                  'event_classificaion_types')
                                              .doc(documentId);
                                      print('Document ID: $documentId');
                                      print(eventTypeRef);
                                      widget.changeMainSection(eventTypeRef);
                                    }
                                  },
                                  child:
                                      Text(classificationData['description']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainSectionContainer extends StatelessWidget {
  final DocumentReference typeEvent;

  const MainSectionContainer({
    Key? key,
    required this.typeEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              if (doc['event_classificaion_types'] == typeEvent) {
                return EventItemDisplay(
                  title: doc['name'].toString(),
                  imageUrl: doc['image_url'].toString(),
                  id: doc.id,
                  onTapFunction: () {
                    // Add your onTap logic here
                  },
                );
              } else {
                return Center(child: Text("لا يوجد مناسبات داخل هذا التصنيف "));
              }
            },
          );
        }
      },
    );
  }
}
