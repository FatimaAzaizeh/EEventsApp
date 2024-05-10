import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/widgets/Event_item.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AddEvent extends StatefulWidget {
  static const String screenRoute = 'NewEvent';
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late String imageUrl;
  Uint8List? fileBytes;
  late String fileName = "No image selected";
  var controllerName = TextEditingController();
  var controllerImage = TextEditingController();
  late DocumentReference eventClassificationRef;
  var controllerId = TextEditingController();
  bool showEditButton = false;
  bool editButton = false;
  List<String> classificationList = [];
  late String name;
  bool showSpinner = false;
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    fetchClassificationsFromFirestore();
  }

  void fetchClassificationsFromFirestore() async {
    final _firestore = FirebaseFirestore.instance;
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
        eventClassificationRef = querySnapshot.docs[0].reference;
        dropdownValue = classificationList.first;
        showSpinner = false;
      });
    } catch (e) {
      print("Error fetching classifications: $e");
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<void> uploadFile() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);

      imageUrl = await uploadTask.ref.getDownloadURL();
      controllerImage.text = imageUrl;
    } catch (error) {
      print('Error uploading file: $error');
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
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
              color: Color.fromARGB(221, 255, 255, 255),
            ),
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
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'المناسبات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 28,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 60, 19, 60),
                          ),
                        ),
                        SizedBox(width: 220),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              controllerName.clear();
                              controllerId.clear();
                              controllerImage.clear();
                              editButton = false;
                            });
                          },
                          child: Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                ),
                TextFieldDesign(
                  Text: 'أسم الخدمة:',
                  icon: Icons.title,
                  ControllerTextField: controllerName,
                  onChanged: (value) {
                    name = value;
                  },
                  obscureTextField: false,
                  enabled: true,
                ),
                TextFieldDesign(
                  enabled: !editButton,
                  Text: 'رقم المناسبة',
                  icon: Icons.room_service,
                  ControllerTextField: controllerId,
                  onChanged: (value) {},
                  obscureTextField: false,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() async {
                            fileBytes = result.files.first.bytes;
                            fileName = result.files.first.name;

                            await uploadFile();
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
                            style: TextStyle(
                              fontSize: 18,
                              color: fileBytes != null
                                  ? ColorPurple_100 // Set color to ColorPurple_100 if fileBytes is not null
                                  : Colors.grey, // Otherwise, set color to grey
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Center(
                  child: DropdownButton<String>(
                    value: classificationList.isNotEmpty ? dropdownValue : null,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? value) {
                      setState(() async {
                        dropdownValue = value!;
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('event_classificaion_types')
                            .where('description', isEqualTo: value)
                            .get();

// Check if any documents match the query
                        if (querySnapshot.docs.isNotEmpty) {
                          // Get the reference to the first document that matches the query
                          eventClassificationRef =
                              querySnapshot.docs[0].reference;
                          // Now you have a reference to the document that matches the condition
                        } else {
                          // Handle the case where no documents match the query
                        }
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
                ),
                Container(
                  width: double.maxFinite,
                  margin: EdgeInsets.only(bottom: 90),
                  child: FloatingActionButton(
                    backgroundColor: ColorPink_100,
                    child: Text(
                      'إضافة مناسبة',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      setState(() async {
                        showSpinner = true;

                        EventType newEvent = EventType(
                            id: controllerId.text,
                            name: controllerName.text,
                            imageUrl: imageUrl,
                            event_classificaion_types: eventClassificationRef);

                        newEvent.addToFirestore();
                        controllerName.clear();
                        controllerId.clear();
                        controllerImage.clear();
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                        );
                        showSpinner = false;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: editButton
                      ? () {
                          EventType.updateEventTypeFirestore(
                              controllerName.text,
                              imageUrl,
                              eventClassificationRef,
                              controllerId.text);
                          setState(() {
                            showEditButton = false;
                          });
                          controllerName.clear();
                          controllerId.clear();
                          controllerImage.clear();
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                          );
                          editButton = false;
                        }
                      : null, // Set onPressed to null when editButton is false
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

  Future<void> getDataById(String documentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('event_types')
        .doc(documentId)
        .get();

    if (snapshot.exists) {
      // Retrieve the reference to 'event_classificaion_types'
      DocumentReference? eventClassificationRef =
          snapshot.get('event_classificaion_types');

      // Check if the reference exists
      if (eventClassificationRef != null) {
        // Get the referenced document
        DocumentSnapshot eventDocSnapshot = await eventClassificationRef.get();

        // Check if the referenced document exists
        if (eventDocSnapshot.exists) {
          // Retrieve the data
          Map<String, dynamic> eventData =
              eventDocSnapshot.data() as Map<String, dynamic>;

          // Now you can access the data using the field name
          setState(() {
            dropdownValue = eventData['description'].toString();
          });
        } else {
          // Handle the case where the referenced document doesn't exist
        }
      } else {
        // Handle the case where the reference is null
      }

      // Now you can update other UI elements outside setState
      setState(() {
        imageUrl = snapshot.get('image_url');
        controllerName.text = snapshot.get('name');
        controllerId.text = snapshot.get('id');
        editButton = true;
      });
    }
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
