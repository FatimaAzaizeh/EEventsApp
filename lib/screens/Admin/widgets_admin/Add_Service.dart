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
import 'package:testtapp/models/ServiceType.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/widgets/Event_item.dart';

// Other import statements and code

final _firestore = FirebaseFirestore.instance;

class AddService extends StatefulWidget {
  static const String screenRoute = 'Add_Service';
  const AddService({Key? key}) : super(key: key);

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  late String imageUrl;
  Uint8List? fileBytes;
  Future<void> uploadFile() async {
    setState(() {
      showSpinner = true; // Show spinner before uploading file
    });

    try {
      // Upload file to Firebase Storage
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);

      // Get download URL of the uploaded file
      imageUrl = await uploadTask.ref.getDownloadURL();
      ControllerImage.text = imageUrl;
    } catch (error) {
      print('Error uploading file: $error');
      // Handle error
    } finally {
      setState(() {
        showSpinner = false; // Hide spinner after upload completes
      });
    }
  }

  String fileName = "لم يتم اختيار صورة ";
  var ControllerName = TextEditingController();
  var ControllerImage = TextEditingController();
  var ControllerId = TextEditingController();
  bool showEditButton = false;
  final _auth = FirebaseAuth.instance;
  late String name; // Name of the Event

  bool showSpinner = false;
  late String dropdownValue;
  List<String> classificationList = []; // Initialize classification list
  late String id;
  bool isButtonEnabled = false;

//edit
  Future<void> getDataById(String documentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('service_types')
        .doc(documentId) // Use document ID directly
        .get();

    if (snapshot.exists) {
      setState(() {
        // Document with the provided ID exists
        ControllerName.text = snapshot.get('name');
        ControllerImage.text = snapshot.get('image_url');

        showEditButton = true;
        id = documentId;
        isButtonEnabled = true;
      });
    } else {
      // Document with the provided ID does not exist
      print("Document not found for ID: $documentId");
    }
  }

  void EditEvent(String documentId) {
    setState(() {
      var docRef =
          FirebaseFirestore.instance.collection('EventType').doc(documentId);

      docRef.update({
        'name': ControllerName.text,
        'id': ControllerId.text,
        'image_url': ControllerImage.text,
      }).then((_) {
        print("Document updated successfully.");
      }).catchError((error) {
        print("Failed to update document: $error");
      });
      showEditButton = false;
      ControllerName.clear();
      ControllerId.clear();
      ControllerImage.clear();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceAround, // Distributes space evenly between the children
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
                        Text('الخدمات',
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
                          onPressed: isButtonEnabled
                              ? () {
                                  EditEvent(id);
                                  isButtonEnabled = false;
                                }
                              : null,
                          child: Icon(Icons.edit),
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
                      name = value; // Update the Name variable
                      // Update the serviceType list
                    },
                    obscureTextField: false),
                TextFieldDesign(
                    Text: 'رقم الخدمة',
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
                    width: double.maxFinite,
                    margin: EdgeInsets.only(bottom: 90),
                    child: FloatingActionButton(
                      backgroundColor: ColorPink_100,
                      child: Text('إضافة خدمة',
                          style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() async {
                          showSpinner = true;
                          await uploadFile(); // Upload file before creating user
                          ServiceType newservice = ServiceType(
                              id: ControllerId.text,
                              name: ControllerName.text,
                              imageUrl: ControllerImage.text);

                          newservice.saveToDatabase();

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
            child: ServiceScreen(),
          ),
        ),
      ],
    );
  }

  SafeArea ServiceScreen() {
    return SafeArea(
      child: Material(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_types')
              .orderBy('id')
              .snapshots(),
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
                  maxCrossAxisExtent:
                      150, // Adjust according to your requirement
                  childAspectRatio: 1, // Ensure each item is square
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
