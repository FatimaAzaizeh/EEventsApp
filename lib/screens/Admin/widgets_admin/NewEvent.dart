import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/models/FirestoreService.dart';
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
  late String fileName = "لم يتم اختيار صورة";
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
              border: Border.all(
                  color:
                      const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
                  width: 3),
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
            ),
            width: 500,
            height: double.maxFinite,
            child: Column(
              children: [
                Padding(
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
                        onPressed: editButton
                            ? () {
                                setState(() {
                                  controllerName.clear();
                                  controllerId.clear();
                                  controllerImage.clear();
                                  editButton = false;
                                });
                              }
                            : null,
                        child: Icon(Icons.clear),
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
                TextFieldDesign(
                  Text: 'أسم المناسبة:',
                  icon: Icons.title,
                  ControllerTextField: controllerName,
                  onChanged: (value) {
                    name = value;
                  },
                  obscureTextField: false,
                  enabled: true,
                ),
                TextFieldDesign(
                  enabled: false,
                  Text: 'يتم تعيين رقم معرّف المناسبة تلقائيًا.',
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
                    style: StyleTextAdmin(14, AdminButton),
                    underline: Container(
                      height: 2,
                      color: ColorPurple_100,
                    ),
                    onChanged: (String? value) async {
                      if (value != null) {
                        setState(() {
                          dropdownValue = value;
                        });

                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('event_classificaion_types')
                            .where('description', isEqualTo: value)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          setState(() {
                            eventClassificationRef =
                                querySnapshot.docs[0].reference;
                          });
                        } else {
                          // Handle the case where no documents match the query
                          // Optionally, show a message or take other actions
                        }
                      }
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
                  width: 200,
                  margin: EdgeInsets.only(bottom: 90),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(165, 255, 255, 255)
                            .withOpacity(0.3),
                        width: 2),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.17),
                  ),
                  child: TextButton(
                    child: Text('إضافة مناسبة',
                        style: StyleTextAdmin(16, AdminButton)),
                    onPressed: () async {
                      setState(() async {
                        showSpinner = true;
                        int count = await FirestoreService.getCountOfRecords(
                            'event_types');
                        int id = count + 1;
                        EventType newEvent = EventType(
                          id: id.toString(),
                          name: controllerName.text,
                          imageUrl: imageUrl,
                          event_classificaion_types: eventClassificationRef,
                        );

                        // Add the event to Firestore and wait for the result
                        String result = await newEvent.addToFirestore();

                        // Clear text controllers regardless of the result
                        controllerName.clear();
                        controllerId.clear();
                        controllerImage.clear();

                        // Update UI based on the result

                        // If addition was successful, show success message
                        QuickAlert.show(
                          context: context,
                          text: result,
                          type: QuickAlertType.info,
                        );

                        // Set spinner to false after processing is done
                        showSpinner = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
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
        color: ColorPink_20,
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
