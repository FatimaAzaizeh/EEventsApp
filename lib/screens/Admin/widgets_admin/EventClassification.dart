import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Classification.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AlertAddClass.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/widgets/Event_item.dart';

class EventClassification extends StatefulWidget {
  static const String screenRoute = 'EventClassification';
  const EventClassification({Key? key}) : super(key: key);

  @override
  State<EventClassification> createState() => _EventClassificationState();
}

bool editButton = false;
String Id = "";
TextEditingController ControllerDescription = TextEditingController();

class _EventClassificationState extends State<EventClassification> {
  late DocumentReference eventTypeRef;
  late Widget _currentMainSection;
  bool showAllEvents = true; // Show all events by default

  @override
  void initState() {
    super.initState();
    eventTypeRef = FirebaseFirestore.instance
        .collection('event_classificaion_types')
        .doc('2');
    _currentMainSection = MainSectionContainer(
      typeEvent: eventTypeRef,
      showAllEvents: showAllEvents,
    );
  }

  void _changeMainSection(DocumentReference newTypeEvent) {
    setState(() {
      eventTypeRef = newTypeEvent;
      _currentMainSection = MainSectionContainer(
        typeEvent: eventTypeRef,
        showAllEvents: showAllEvents,
      );
    });
  }

  void toggleShowAllEvents() {
    setState(() {
      showAllEvents = !showAllEvents;
      _currentMainSection = MainSectionContainer(
        typeEvent: eventTypeRef,
        showAllEvents: showAllEvents,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
                  width: 2),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.3),
            ),
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddClassification(),
                );
              },
              child: Text('إضافة تصنيف جديد',
                  style: StyleTextAdmin(16, AdminButton)),
            ),
          ),
        ),
        Row(
          children: [
            TextFieldDesign(
              enabled: editButton,
              Text: ControllerDescription.text,
              icon: Icons.category,
              ControllerTextField: ControllerDescription,
              onChanged: (value) {},
              obscureTextField: false,
            ),
            Tooltip(
              decoration: BoxDecoration(color: Colors.white),
              textStyle: StyleTextAdmin(12, ColorPurple_100),
              message: 'تعديل اسم التصنيف',
              child: IconButton(
                disabledColor: Colors.grey,
                color: ColorPink_100,
                onPressed: editButton
                    ? () async {
                        if (ControllerDescription.text.isNotEmpty) {
                          Future<bool> editclass =
                              Classification.updateClassificationFirestore(
                                  Id, ControllerDescription.text);
                          setState(() {
                            editButton = false;
                            ControllerDescription.clear();
                            Id = '';
                          });
                          if (await editclass) {
                            SuccessAlert(context, 'تم تعديل اسم التصنيف بنجاح');
                          } else {
                            ErrorAlert(context, 'خطأ',
                                'حدث خطأ, لم يتم تعديل إسم التصنيف ');
                          }
                        } else {
                          ErrorAlert(context, 'خطأ',
                              'الرجاء إدخال كل البيانات المطلوبة');
                        }
                      }
                    : null,
                icon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
        ClassificationTypes(changeMainSection: _changeMainSection),
        Container(
          width: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.3),
          ),
          child: TextButton(
            onPressed: toggleShowAllEvents,
            child: Text(
              showAllEvents ? 'عرض التصنيفات' : 'عرض الكل',
              style: StyleTextAdmin(14, AdminButton.withOpacity(0.75)),
            ),
          ),
        ),
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
                                    setState(() {
                                      if (querySnapshot.docChanges.isNotEmpty) {
                                        var firstChange =
                                            querySnapshot.docChanges.first;
                                        var docSnapshot = firstChange.doc;
                                        var fieldValue =
                                            docSnapshot['description'];
                                        ControllerDescription.text = fieldValue;
                                      }
                                      editButton = true;
                                    });

                                    for (QueryDocumentSnapshot document
                                        in querySnapshot.docs) {
                                      String documentId = document.id;
                                      Id = documentId;
                                      DocumentReference eventTypeRef =
                                          FirebaseFirestore.instance
                                              .collection(
                                                  'event_classificaion_types')
                                              .doc(documentId);

                                      widget.changeMainSection(eventTypeRef);
                                    }
                                  },
                                  child: Text(classificationData['description'],
                                      style: StyleTextAdmin(
                                          16, AdminButton.withOpacity(0.7))),
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
  final bool showAllEvents;

  const MainSectionContainer({
    Key? key,
    required this.typeEvent,
    required this.showAllEvents,
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

          // Filter events based on the selected classification type if not showing all events
          final filteredEvents = showAllEvents
              ? eventDocs
              : eventDocs
                  .where((doc) => doc['event_classificaion_types'] == typeEvent)
                  .toList();

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150, // Adjust box size as needed
              childAspectRatio: 1, // Square aspect ratio
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final doc = filteredEvents[index];
              return EventItemDisplay(
                title: doc['name'].toString(),
                imageUrl: doc['image_url'].toString(),
                id: doc.id,
                onTapFunction: () {
                  // Add your onTap logic here
                },
              );
            },
          );
        }
      },
    );
  }
}
