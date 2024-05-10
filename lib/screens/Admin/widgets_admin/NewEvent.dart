import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/screens/Admin/widgets_admin/ClassificationDropDown.dart';
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
  late String imageUrl;
  Uint8List? fileBytes;
  late String fileName = "لم يتم اختيار صورة ";
  var ControllerName = TextEditingController();
  var ControllerImage = TextEditingController();
  late DocumentReference Classification;
  var ControllerId = TextEditingController();
  bool showEditButton = false;
  final _auth = FirebaseAuth.instance;
  late String name;
  bool showSpinner = false;
  late String dropdownValue;
  List<String> classificationList = [];
  late String id;
  bool isButtonEnabled = false;

  Future<void> uploadFile() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);

      imageUrl = await uploadTask.ref.getDownloadURL();
      ControllerImage.text = imageUrl;
    } catch (error) {
      print('Error uploading file: $error');
    } finally {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            child: Column(
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
                        Text('المناسبات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 60, 19, 60))),
                        SizedBox(
                          width: 220,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                ControllerName.clear();
                                ControllerId.clear();
                                ControllerImage.clear();
                                isButtonEnabled = false;
                              });
                            },
                            child: Icon(Icons.clear)),
                      ],
                    ),
                  ),
                ),
                TextFieldDesign(
                    Text: 'أسم الخدمة:',
                    icon: Icons.title,
                    ControllerTextField: ControllerName,
                    onChanged: (value) {
                      name = value;
                    },
                    obscureTextField: false),
                TextFieldDesign(
                    Text: 'رقم المناسبة',
                    icon: Icons.room_service,
                    ControllerTextField: ControllerId,
                    onChanged: (value) {
                      ControllerId.text = value;
                    },
                    obscureTextField: false),
                Row(children: [
                  TextButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          fileBytes = result.files.first.bytes;
                          fileName = result.files.first.name;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'إضافة صورة',
                          child: Icon(
                            Icons.add,
                            size: 34,
                            color: ColorPurple_100,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          fileName,
                          style: StyleTextAdmin(
                            18,
                            fileBytes != null ? ColorPurple_100 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                Container(
                  child: ClassificationDropdown(
                    onClassificationSelected: (classification) {
                      print('Selected classification: $classification');
                    },
                  ),
                ),
                Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.only(bottom: 90),
                    child: FloatingActionButton(
                      backgroundColor: ColorPink_100,
                      child: Text('إضافة مناسبة',
                          style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() async {
                          showSpinner = true;
                          await uploadFile();
                          EventType newEvent = EventType(
                              id: ControllerId.text,
                              name: ControllerName.text,
                              imageUrl: ControllerImage.text,
                              event_classificaion_types: Classification);
                          newEvent.addToFirestore();
                          ControllerName.clear();
                          ControllerId.clear();
                          ControllerImage.clear();
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                          );
                          showSpinner = false;
                        });
                      },
                    )),
                IconButton(
                  onPressed: () {
                    EventType.updateEventTypeFirestore(ControllerName.text,
                        ControllerImage.text, Classification, id);
                    showEditButton = false;
                    ControllerName.clear();
                    ControllerId.clear();
                    ControllerImage.clear();
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
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
