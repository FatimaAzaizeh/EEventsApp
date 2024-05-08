import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/widgets/Event_item.dart';

final _firestore = FirebaseFirestore.instance;

class AddEvent extends StatefulWidget {
  static const String screenRoute = 'NewEvent';
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  var ControllerName = TextEditingController();
  var ControllerImage = TextEditingController();
  var ControllerSer = TextEditingController();
  bool showEditButton = false;
  final _auth = FirebaseAuth.instance;
  late String name; // Name of the Event
  late String classification = ''; // Classification of the Event
  late String ImageUrl;
  bool showSpinner = false;
  late String dropdownValue;
  List<String> classificationList = [];
  late String id;
  bool isButtonEnabled = false;

  void fetchClassificationsFromFirestore() async {
    try {
      setState(() {
        showSpinner = true;
      });

      QuerySnapshot querySnapshot =
          await _firestore.collection("event_classificaion_types").get();

      setState(() {
        classificationList.clear();
      });

      for (var docSnapshot in querySnapshot.docs) {
        classificationList.add(docSnapshot.get('description').toString());
      }

      setState(() {
        dropdownValue = (classificationList.isNotEmpty
            ? classificationList.first.toString()
            : null)!;
        showSpinner = false;
      });
    } catch (e) {
      print("Error fetching classifications: $e");
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<void> getDataById(String documentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('event_types')
        .doc(documentId)
        .get();

    if (snapshot.exists) {
      setState(() {
        ControllerName.text = snapshot.get('name');

        ControllerImage.text = snapshot.get('image_url');
        showEditButton = true;
        id = documentId;
        isButtonEnabled = true;
      });
    } else {
      print("Document not found for ID: $documentId");
    }
  }

  void EditEvent(String documentId) {
    setState(() {
      var docRef =
          FirebaseFirestore.instance.collection('event_types').doc(documentId);

      docRef.update({
        'name': ControllerName.text,
        'event_classificaion_types': ControllerSer,
        'image_url': ControllerImage.text,
      }).then((_) {
        print("Document updated successfully.");
      }).catchError((error) {
        print("Failed to update document: $error");
      });
      showEditButton = false;
      ControllerName.clear();
      ControllerSer.clear();
      ControllerImage.clear();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
      );
    });
  }

  void DelEvent(String documentId) {
    setState(() {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.confirm,
          text: 'Do you want to logout?',
          confirmBtnText: 'Yes',
          cancelBtnText: 'No',
          confirmBtnColor: Colors.green,
          onConfirmBtnTap: () {
            var docRef = FirebaseFirestore.instance
                .collection('event_types')
                .doc(documentId)
                .delete();
            Navigator.of(context).pop();
          },
          onCancelBtnTap: () {
            Navigator.of(context).pop();
          });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchClassificationsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap with SingleChildScrollView
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color.fromARGB(221, 255, 255, 255)),
              width: 500,
              height: double.maxFinite,
              child: SingleChildScrollView(
                // Wrap the Column with SingleChildScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.maxFinite,
                      height: 70,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'المناسبات',
                            ),
                            SizedBox(
                              width: 220,
                            ),
                            // Edit, Delete, Clear buttons...
                          ],
                        ),
                      ),
                    ),
                    TextFieldDesign(
                      Text: 'أسم المناسبة:',
                      icon: Icons.title,
                      ControllerTextField: ControllerName,
                      onChanged: (value) {
                        name = value;
                      },
                      obscureTextField: false,
                    ),
                    DropdownButton<String>(
                      value: classificationList.isNotEmpty
                          ? dropdownValue
                          : 'no item',
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          classification = value!;
                          dropdownValue = value;
                        });
                      },
                      items: classificationList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    TextFieldDesign(
                      Text: 'إضافة صورة:',
                      icon: Icons.image,
                      ControllerTextField: ControllerImage,
                      onChanged: (value) {
                        ImageUrl = value;
                      },
                      obscureTextField: false,
                    ),
                    Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(bottom: 90),
                      child: FloatingActionButton(
                        backgroundColor: ColorPink_100,
                        child: Text('إضافة مناسبة'),
                        onPressed: () async {
                          QuerySnapshot<Map<String, dynamic>> querySnapshot =
                              await FirebaseFirestore.instance
                                  .collection('event_classificaion_types')
                                  .where('description',
                                      isEqualTo: classification)
                                  .get();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              width: 400,
              height: double.maxFinite,
              child: EventScreen(),
            ),
          ),
        ],
      ),
    );
  }

//display the event type exist
  SafeArea EventScreen() {
    return SafeArea(
      child: Material(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('event_types').snapshots(),
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
                    onTapFunction: () {
                      getDataById(doc.id);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
